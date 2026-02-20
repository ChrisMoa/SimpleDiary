// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/backup_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for syncing backup files to/from Supabase Storage.
///
/// Uses Supabase Storage buckets to store encrypted backup files in the cloud.
/// Files are stored under `{userId}/{backupId}.json` in a private bucket.
/// All methods are fail-safe — cloud errors never disrupt local operations.
class CloudBackupService {
  static final CloudBackupService _instance = CloudBackupService._internal();
  factory CloudBackupService() => _instance;
  CloudBackupService._internal();

  String get _bucketName => kDebugMode ? 'test_backups' : 'backups';

  /// Get the Supabase client, or null if not initialized
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Ensure Supabase is initialized and authenticated.
  /// Returns true if ready, false if not configured or auth fails.
  Future<bool> _ensureAuthenticated() async {
    final settings = settingsContainer.activeUserSettings.supabaseSettings;
    if (settings.supabaseUrl.isEmpty ||
        settings.supabaseAnonKey.isEmpty ||
        settings.email.isEmpty ||
        settings.password.isEmpty) {
      LogWrapper.logger.w('Cloud backup: Supabase settings incomplete');
      return false;
    }

    try {
      final api = SupabaseApi(tablePrefix: kDebugMode ? 'test_' : '');
      await api.initialize(settings.supabaseUrl, settings.supabaseAnonKey);

      if (_client?.auth.currentUser == null) {
        final success = await api.signInWithEmailPassword(
          settings.email,
          settings.password,
        );
        if (!success) {
          LogWrapper.logger.e('Cloud backup: Authentication failed');
          return false;
        }
      }
      return true;
    } catch (e) {
      LogWrapper.logger.e('Cloud backup: Authentication error: $e');
      return false;
    }
  }

  /// Get the storage path for a backup file under the current user's folder.
  String _storagePath(String backupId) {
    final userId = _client!.auth.currentUser!.id;
    return '$userId/$backupId.json';
  }

  /// Upload a local backup file to Supabase Storage.
  /// Returns true on success, false on failure. Never throws.
  Future<bool> uploadBackup(BackupMetadata metadata) async {
    try {
      LogWrapper.logger.i('Cloud backup: uploading ${metadata.id}...');
      if (!await _ensureAuthenticated()) return false;

      final file = File(metadata.filePath);
      if (!await file.exists()) {
        LogWrapper.logger.e('Cloud backup: local file not found: ${metadata.filePath}');
        return false;
      }

      final bytes = await file.readAsBytes();
      final path = _storagePath(metadata.id);

      await _client!.storage.from(_bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      LogWrapper.logger.i(
        'Cloud backup: uploaded ${metadata.id} (${bytes.length} bytes)',
      );
      return true;
    } catch (e) {
      LogWrapper.logger.e('Cloud backup: upload failed: $e');
      return false;
    }
  }

  /// List all cloud backups for the current user.
  /// Returns list of storage file objects, sorted newest first.
  Future<List<FileObject>> listCloudBackups() async {
    try {
      if (!await _ensureAuthenticated()) return [];

      final userId = _client!.auth.currentUser!.id;
      final files = await _client!.storage.from(_bucketName).list(path: userId);

      // Sort by name descending (names contain timestamps, so newest first)
      files.sort((a, b) => b.name.compareTo(a.name));
      return files;
    } catch (e) {
      LogWrapper.logger.e('Cloud backup: list failed: $e');
      return [];
    }
  }

  /// Download a cloud backup to the local backup directory.
  /// Parses the backup envelope to build metadata and saves to local index.
  /// Returns the local BackupMetadata on success, null on failure.
  Future<BackupMetadata?> downloadBackup(String backupId) async {
    try {
      LogWrapper.logger.i('Cloud backup: downloading $backupId...');
      if (!await _ensureAuthenticated()) return null;

      final path = _storagePath(backupId);
      final bytes = await _client!.storage.from(_bucketName).download(path);

      // Write to local backup directory
      final backupDir = await BackupService().getBackupDirectory();
      final localFile = File('${backupDir.path}/$backupId.json');
      await localFile.writeAsBytes(bytes);

      // Parse the backup envelope for metadata (counts are in the envelope)
      final content = utf8.decode(bytes);
      final envelope = jsonDecode(content) as Map<String, dynamic>;

      final metadata = BackupMetadata(
        id: backupId,
        createdAt: DateTime.parse(envelope['createdAt'] as String),
        sizeBytes: bytes.length,
        filePath: localFile.path,
        type: BackupType.fromJson(envelope['type'] as String? ?? 'manual'),
        diaryDayCount: envelope['diaryDayCount'] as int? ?? 0,
        noteCount: envelope['noteCount'] as int? ?? 0,
        habitCount: envelope['habitCount'] as int? ?? 0,
        habitEntryCount: envelope['habitEntryCount'] as int? ?? 0,
        encrypted: envelope['encrypted'] as bool? ?? false,
        cloudSynced: true,
      );

      // Save to local metadata index
      await BackupService().updateMetadataInIndex(metadata);

      LogWrapper.logger.i(
        'Cloud backup: downloaded $backupId (${bytes.length} bytes)',
      );
      return metadata;
    } catch (e) {
      LogWrapper.logger.e('Cloud backup: download failed: $e');
      return null;
    }
  }

  /// Delete a backup from cloud storage.
  /// Returns true on success, false on failure. Never throws.
  Future<bool> deleteCloudBackup(String backupId) async {
    try {
      if (!await _ensureAuthenticated()) return false;

      final path = _storagePath(backupId);
      await _client!.storage.from(_bucketName).remove([path]);

      LogWrapper.logger.i('Cloud backup: deleted $backupId');
      return true;
    } catch (e) {
      LogWrapper.logger.e('Cloud backup: delete failed: $e');
      return false;
    }
  }
}
