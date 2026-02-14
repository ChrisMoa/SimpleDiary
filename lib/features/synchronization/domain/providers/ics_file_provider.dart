import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/synchronization/data/repositories/ics_converter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Metadata for ICS export/import operations
class IcsExportMetadata {
  final String? username;
  final String? salt;
  final DateTime exportDate;
  final bool encrypted;
  final int noteCount;

  IcsExportMetadata({
    this.username,
    this.salt,
    required this.exportDate,
    required this.encrypted,
    required this.noteCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'salt': salt,
      'exportDate': exportDate.toIso8601String(),
      'encrypted': encrypted,
      'noteCount': noteCount,
    };
  }

  factory IcsExportMetadata.fromMap(Map<String, dynamic> map) {
    return IcsExportMetadata(
      username: map['username'] as String?,
      salt: map['salt'] as String?,
      exportDate: DateTime.parse(map['exportDate'] as String),
      encrypted: map['encrypted'] as bool,
      noteCount: map['noteCount'] as int? ?? 0,
    );
  }
}

/// Provider for ICS export/import operations
class IcsFileProvider extends StateNotifier<List<Note>> {
  IcsFileProvider() : super([]);

  final _converter = IcsConverter();

  /// Export notes to ICS file with metadata
  /// [notes] - List of notes to export
  /// [file] - Target file for export
  /// [username] - Optional username for metadata
  /// [salt] - Optional salt for encryption (required if encrypted is true)
  /// [encrypted] - Whether to encrypt the ICS data
  /// [password] - Password for encryption (required if encrypted is true)
  Future<void> exportWithMetadata({
    required List<Note> notes,
    required File file,
    String? username,
    String? salt,
    required bool encrypted,
    String? password,
  }) async {
    LogWrapper.logger.i('ICS export started with metadata');

    try {
      final content = exportToString(
        notes: notes,
        username: username,
        salt: salt,
        encrypted: encrypted,
        password: password,
      );

      // Write to file
      await file.writeAsString(content);

      LogWrapper.logger.i('ICS file with metadata written successfully (${notes.length} notes)');
    } catch (e) {
      LogWrapper.logger.e('Error during ICS export: $e');
      rethrow;
    }
  }

  /// Generate export ICS string with metadata
  /// Returns the JSON string to be saved
  String exportToString({
    required List<Note> notes,
    String? username,
    String? salt,
    required bool encrypted,
    String? password,
  }) {
    // Convert notes to ICS calendar
    final calendar = _converter.createCalendar(notes);
    final icsString = _converter.calendarToString(calendar);

    // Prepare data (encrypted or plain)
    String dataContent;
    if (encrypted && password != null && salt != null) {
      // Encrypt the ICS string
      String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(password, salt);
      var encryptor = AesEncryptor(encryptionKey: encryptionKey);
      dataContent = encryptor.encryptStringAsBase64(icsString);
      LogWrapper.logger.i('ICS data encrypted (${icsString.length} -> ${dataContent.length} chars)');
    } else {
      // Store as plain ICS string
      dataContent = icsString;
    }

    // Create export structure with metadata
    final exportMap = {
      'version': '1.0',
      'format': 'ics',
      'metadata': {
        'username': username,
        'salt': salt,
        'exportDate': DateTime.now().toIso8601String(),
        'encrypted': encrypted,
        'noteCount': notes.length,
      },
      'data': dataContent,
    };

    return jsonEncode(exportMap);
  }

  /// Export notes to plain ICS file without encryption or metadata wrapper
  /// [notes] - List of notes to export
  /// [file] - Target file for export
  Future<void> exportPlainIcs({
    required List<Note> notes,
    required File file,
  }) async {
    LogWrapper.logger.i('Plain ICS export started');

    try {
      // Convert notes to ICS calendar
      final calendar = _converter.createCalendar(notes);
      final icsString = _converter.calendarToString(calendar);

      // Write directly to file as plain ICS
      file.writeAsStringSync(icsString);

      LogWrapper.logger.i('Plain ICS file written successfully (${notes.length} notes)');
    } catch (e) {
      LogWrapper.logger.e('Error during plain ICS export: $e');
      rethrow;
    }
  }

  /// Import notes from ICS file with automatic format detection
  /// Supports both wrapped format (with metadata) and plain ICS files
  /// [file] - Source file to import from
  /// [password] - Password for decryption (required if file is encrypted)
  /// Returns the metadata if available, null for plain ICS files
  Future<IcsExportMetadata?> importFromIcs(File file, {String? password}) async {
    LogWrapper.logger.t('ICS import started');
    state = [];

    try {
      // Read file content
      String fileContent = file.readAsStringSync();

      IcsExportMetadata? metadata;
      String icsString;

      // Check if it's a wrapped format with metadata
      if (_isWrappedFormat(fileContent)) {
        LogWrapper.logger.i('Detected wrapped ICS format with metadata');

        final Map<String, dynamic> exportMap = jsonDecode(fileContent);
        final metadataMap = exportMap['metadata'] as Map<String, dynamic>;
        metadata = IcsExportMetadata.fromMap(metadataMap);

        final dataContent = exportMap['data'] as String;

        // Decrypt if needed
        if (metadata.encrypted) {
          if (password == null || password.isEmpty) {
            throw Exception('Password required for encrypted ICS file');
          }
          if (metadata.salt == null) {
            throw Exception('Salt missing in encrypted ICS file metadata');
          }

          String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(
            password,
            metadata.salt!,
          );
          var encryptor = AesEncryptor(encryptionKey: encryptionKey);
          icsString = encryptor.decryptStringFromBase64(dataContent);
          LogWrapper.logger.i('ICS data decrypted successfully');
        } else {
          icsString = dataContent;
        }
      } else {
        LogWrapper.logger.i('Detected plain ICS format');
        icsString = fileContent;
      }

      // Parse ICS string to notes
      final calendar = _converter.stringToCalendar(icsString);
      final notes = _converter.icsEventsToNotes(calendar);

      state = [...notes];
      LogWrapper.logger.t('ICS import finished (${notes.length} notes)');

      return metadata;
    } catch (e) {
      LogWrapper.logger.e('Error during ICS import: $e');
      rethrow;
    }
  }

  /// Check if file content is in wrapped format (JSON with metadata)
  bool _isWrappedFormat(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded.containsKey('version') &&
            decoded.containsKey('format') &&
            decoded.containsKey('metadata') &&
            decoded['format'] == 'ics';
      }
      return false;
    } catch (e) {
      // Not JSON, so it's a plain ICS file
      return false;
    }
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final icsFileStateProvider =
    StateNotifierProvider<IcsFileProvider, List<Note>>((ref) {
  return IcsFileProvider();
});
