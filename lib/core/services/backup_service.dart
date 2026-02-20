// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';

/// Service for creating, restoring, and managing local backup files.
///
/// Backups are stored as versioned JSON files in a dedicated backup directory.
/// Each backup captures diary days, notes, habits, and habit entries.
/// Backup data is encrypted using AES-256-CBC with the user's password-derived key.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static const String _backupSubDir = 'backups';
  static const String _metadataFileName = 'backup_index.json';

  /// Get the backup directory path, creating it if needed
  Future<Directory> getBackupDirectory() async {
    final customPath = settingsContainer.activeUserSettings.backupSettings.backupDirectoryPath;
    final basePath = customPath ?? settingsContainer.applicationDocumentsPath;
    final dir = Directory('$basePath/$_backupSubDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Create an [AesEncryptor] from the current user's credentials.
  /// Returns null if no clear password is available (user not logged in).
  AesEncryptor? _createEncryptor() {
    final userData = settingsContainer.activeUserSettings.savedUserData;
    final clearPassword = userData.clearPassword;
    final salt = userData.salt;

    if (clearPassword.isEmpty || salt.isEmpty) {
      LogWrapper.logger.w('Cannot create encryptor: missing password or salt');
      return null;
    }

    final encryptionKey =
        PasswordAuthService.getDatabaseEncryptionKey(clearPassword, salt);
    return AesEncryptor(encryptionKey: encryptionKey);
  }

  /// Create a backup from raw data maps.
  ///
  /// [diaryDaysJson] - List of diary day maps (from toMap())
  /// [notesJson] - List of note maps (from toLocalDbMap())
  /// [habitsJson] - List of habit maps (from toLocalDbMap())
  /// [habitEntriesJson] - List of habit entry maps (from toLocalDbMap())
  /// [type] - What triggered this backup
  Future<BackupMetadata> createBackup({
    required List<Map<String, dynamic>> diaryDaysJson,
    required List<Map<String, dynamic>> notesJson,
    required List<Map<String, dynamic>> habitsJson,
    required List<Map<String, dynamic>> habitEntriesJson,
    required BackupType type,
  }) async {
    LogWrapper.logger.i('Creating ${type.name} backup...');

    final now = DateTime.now();
    final id = 'backup_${now.toIso8601String().replaceAll(':', '-')}';
    final backupDir = await getBackupDirectory();
    final filePath = '${backupDir.path}/$id.json';

    try {
      // Build the plain-text data payload
      final dataMap = {
        'diaryDays': diaryDaysJson,
        'notes': notesJson,
        'habits': habitsJson,
        'habitEntries': habitEntriesJson,
      };

      // Encrypt data if credentials are available
      final encryptor = _createEncryptor();
      final bool encrypted = encryptor != null;
      dynamic dataField;

      if (encrypted) {
        final plainDataJson = jsonEncode(dataMap);
        dataField = encryptor.encryptStringAsBase64(plainDataJson);
        LogWrapper.logger.i(
          'Backup data encrypted (${plainDataJson.length} → ${(dataField as String).length} chars)',
        );
      } else {
        dataField = dataMap;
        LogWrapper.logger.w('Backup created WITHOUT encryption (no credentials available)');
      }

      final backupContent = {
        'version': '2.0',
        'createdAt': now.toIso8601String(),
        'type': type.toJson(),
        'encrypted': encrypted,
        'diaryDayCount': diaryDaysJson.length,
        'noteCount': notesJson.length,
        'habitCount': habitsJson.length,
        'habitEntryCount': habitEntriesJson.length,
        'data': dataField,
      };

      final jsonString = jsonEncode(backupContent);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      final metadata = BackupMetadata(
        id: id,
        createdAt: now,
        sizeBytes: await file.length(),
        filePath: filePath,
        type: type,
        diaryDayCount: diaryDaysJson.length,
        noteCount: notesJson.length,
        habitCount: habitsJson.length,
        habitEntryCount: habitEntriesJson.length,
        encrypted: encrypted,
      );

      await _saveMetadataToIndex(metadata);

      // Update last backup timestamp in settings
      settingsContainer.activeUserSettings.backupSettings.lastBackupTimestamp =
          now.toIso8601String();
      await settingsContainer.saveSettings();

      LogWrapper.logger.i(
        'Backup created: $id (${metadata.formattedSize}, '
        '${diaryDaysJson.length} days, ${notesJson.length} notes, '
        '${habitsJson.length} habits, encrypted: $encrypted)',
      );

      // Prune old backups after successful creation
      await pruneOldBackups();

      return metadata;
    } catch (e) {
      LogWrapper.logger.e('Failed to create backup: $e');

      // Still record the failed backup in metadata
      final metadata = BackupMetadata(
        id: id,
        createdAt: now,
        sizeBytes: 0,
        filePath: filePath,
        type: type,
        diaryDayCount: 0,
        noteCount: 0,
        habitCount: 0,
        habitEntryCount: 0,
        error: e.toString(),
      );
      await _saveMetadataToIndex(metadata);
      return metadata;
    }
  }

  /// Read backup content from a backup file.
  ///
  /// Returns a map with keys: diaryDays, notes, habits, habitEntries
  /// Each value is a `List<Map<String, dynamic>>`.
  /// Automatically decrypts encrypted backups using the current user's credentials.
  Future<Map<String, List<Map<String, dynamic>>>> readBackupContent(
    String backupId,
  ) async {
    final metadata = await getBackupMetadata(backupId);
    if (metadata == null) {
      throw Exception('Backup not found: $backupId');
    }

    final file = File(metadata.filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found: ${metadata.filePath}');
    }

    final jsonString = await file.readAsString();
    final backupMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final isEncrypted = backupMap['encrypted'] as bool? ?? false;

    Map<String, dynamic> data;

    if (isEncrypted) {
      final encryptor = _createEncryptor();
      if (encryptor == null) {
        throw Exception('Cannot decrypt backup: no credentials available');
      }

      final encryptedData = backupMap['data'] as String;
      try {
        final decryptedJson = encryptor.decryptStringFromBase64(encryptedData);
        data = jsonDecode(decryptedJson) as Map<String, dynamic>;
      } catch (e) {
        throw Exception(
          'Failed to decrypt backup. Wrong password or corrupted file. Details: $e',
        );
      }
    } else {
      data = backupMap['data'] as Map<String, dynamic>;
    }

    return {
      'diaryDays': List<Map<String, dynamic>>.from(
        (data['diaryDays'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      'notes': List<Map<String, dynamic>>.from(
        (data['notes'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      'habits': List<Map<String, dynamic>>.from(
        (data['habits'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      'habitEntries': List<Map<String, dynamic>>.from(
        (data['habitEntries'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    };
  }

  /// List all backups, sorted by creation date (newest first)
  Future<List<BackupMetadata>> listBackups() async {
    final index = await _loadMetadataIndex();
    index.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return index;
  }

  /// Get metadata for a specific backup
  Future<BackupMetadata?> getBackupMetadata(String backupId) async {
    final index = await _loadMetadataIndex();
    try {
      return index.firstWhere((m) => m.id == backupId);
    } catch (_) {
      return null;
    }
  }

  /// Delete a specific backup file and its metadata
  Future<void> deleteBackup(String backupId) async {
    LogWrapper.logger.i('Deleting backup: $backupId');
    final index = await _loadMetadataIndex();
    final metadata = index.where((m) => m.id == backupId).firstOrNull;

    if (metadata != null) {
      // Delete the backup file
      final file = File(metadata.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from index
      index.removeWhere((m) => m.id == backupId);
      await _writeMetadataIndex(index);
    }
  }

  /// Remove old backups exceeding the max count setting
  Future<void> pruneOldBackups() async {
    final maxBackups = settingsContainer.activeUserSettings.backupSettings.maxBackups;
    final index = await _loadMetadataIndex();

    // Only prune successful backups; keep failures for debugging
    final successful = index.where((m) => m.isSuccessful).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (successful.length <= maxBackups) return;

    final toDelete = successful.sublist(maxBackups);
    for (final backup in toDelete) {
      LogWrapper.logger.d('Pruning old backup: ${backup.id}');
      final file = File(backup.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      index.removeWhere((m) => m.id == backup.id);
    }

    await _writeMetadataIndex(index);
    LogWrapper.logger.i('Pruned ${toDelete.length} old backups');
  }

  /// Calculate total storage used by all backups
  Future<int> getStorageUsageBytes() async {
    final index = await _loadMetadataIndex();
    return index.fold<int>(0, (sum, m) => sum + m.sizeBytes);
  }

  /// Update metadata for an existing backup in the index.
  /// Used by CloudBackupService to mark backups as cloud-synced.
  Future<void> updateMetadataInIndex(BackupMetadata metadata) async {
    await _saveMetadataToIndex(metadata);
  }

  // -- Index file management --

  Future<File> _getIndexFile() async {
    final dir = await getBackupDirectory();
    return File('${dir.path}/$_metadataFileName');
  }

  Future<List<BackupMetadata>> _loadMetadataIndex() async {
    try {
      final file = await _getIndexFile();
      if (!await file.exists()) return [];
      final jsonString = await file.readAsString();
      final list = jsonDecode(jsonString) as List;
      return list
          .map((e) => BackupMetadata.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      LogWrapper.logger.e('Failed to load backup index: $e');
      return [];
    }
  }

  Future<void> _writeMetadataIndex(List<BackupMetadata> index) async {
    final file = await _getIndexFile();
    final jsonString = jsonEncode(index.map((m) => m.toMap()).toList());
    await file.writeAsString(jsonString);
  }

  Future<void> _saveMetadataToIndex(BackupMetadata metadata) async {
    final index = await _loadMetadataIndex();
    // Replace if exists (e.g., retry), otherwise add
    index.removeWhere((m) => m.id == metadata.id);
    index.add(metadata);
    await _writeMetadataIndex(index);
  }
}
