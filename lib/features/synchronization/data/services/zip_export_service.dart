import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:path/path.dart' as p;

/// Result of importing a ZIP archive.
class ZipImportResult {
  final List<DiaryDay> diaryDays;
  final List<NoteAttachment> attachments;
  final ExportMetadata? metadata;

  ZipImportResult({
    required this.diaryDays,
    required this.attachments,
    this.metadata,
  });
}

/// Service for creating and extracting ZIP archives that bundle
/// diary data (JSON) with photo attachments (image files).
///
/// ZIP structure:
/// ```
/// backup.zip
/// ├── manifest.json           # ExportData JSON (v1.1) with attachment metadata
/// └── images/
///     └── <noteId>/
///         └── <attachmentId>.<ext>
/// ```
class ZipExportService {
  /// Creates a ZIP archive containing diary data and image files.
  ///
  /// Returns the ZIP as raw bytes.
  List<int> createZipExport({
    required List<DiaryDay> diaryDays,
    required List<NoteAttachment> attachments,
    String? username,
    String? salt,
    required bool encrypted,
    String? password,
  }) {
    final archive = Archive();

    // Build attachment manifest and add image files
    final attachmentMaps = <Map<String, dynamic>>[];

    for (final attachment in attachments) {
      final file = File(attachment.filePath);
      final ext = p.extension(attachment.filePath);
      final zipPath = 'images/${attachment.noteId}/${attachment.id}$ext';

      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        archive.addFile(ArchiveFile(zipPath, bytes.length, bytes));
        attachmentMaps.add({
          ...attachment.toMap(),
          'zipPath': zipPath,
        });
      } else {
        LogWrapper.logger.w(
          'ZipExportService: image file missing, skipping: ${attachment.filePath}',
        );
        attachmentMaps.add({
          ...attachment.toMap(),
          'zipPath': null,
        });
      }
    }

    // Build diary data (optionally encrypted)
    String dataJson;
    if (encrypted && password != null && salt != null) {
      final plainDataJson =
          jsonEncode(diaryDays.map((d) => d.toMap()).toList());
      final encryptionKey =
          PasswordAuthService.getDatabaseEncryptionKey(password, salt);
      final encryptor = AesEncryptor(encryptionKey: encryptionKey);
      dataJson = encryptor.encryptStringAsBase64(plainDataJson);
    } else {
      dataJson = jsonEncode(diaryDays.map((d) => d.toMap()).toList());
    }

    // Build manifest
    final manifestMap = {
      'version': '1.1',
      'metadata': {
        'username': username,
        'salt': salt,
        'exportDate': DateTime.now().toIso8601String(),
        'encrypted': encrypted,
      },
      'data': dataJson,
      'attachments': attachmentMaps,
    };

    final manifestJson = jsonEncode(manifestMap);
    final manifestBytes = utf8.encode(manifestJson);
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    LogWrapper.logger.i(
      'ZipExportService: created archive with ${diaryDays.length} diary days, '
      '${attachmentMaps.where((a) => a['zipPath'] != null).length} images',
    );

    return ZipEncoder().encode(archive);
  }

  /// Extracts a ZIP archive, restores image files, and returns parsed data.
  ///
  /// [zipFile] — the ZIP file to import
  /// [targetImageDir] — local images directory (e.g. `<appDocs>/images`)
  /// [password] — decryption password (required if manifest is encrypted)
  ZipImportResult extractZipImport({
    required File zipFile,
    required String targetImageDir,
    String? password,
  }) {
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find and parse manifest.json
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw Exception('Invalid ZIP archive: no manifest.json found');
    }

    final manifestJson = utf8.decode(manifestFile.content as List<int>);
    final manifestMap = jsonDecode(manifestJson) as Map<String, dynamic>;

    // Parse using ExportData (handles encryption, backward compat)
    final exportData = ExportData.fromMap(manifestMap, password: password);

    // Extract image files from ZIP and create local attachment records
    final attachmentMaps =
        (manifestMap['attachments'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final restoredAttachments = <NoteAttachment>[];

    for (final attachMap in attachmentMaps) {
      final zipPath = attachMap['zipPath'] as String?;
      if (zipPath == null) continue;

      final archiveFile = archive.findFile(zipPath);
      if (archiveFile == null) {
        LogWrapper.logger.w(
          'ZipExportService: image referenced in manifest not found in ZIP: $zipPath',
        );
        continue;
      }

      final ext = p.extension(zipPath);
      final noteId = attachMap['noteId'] as String;
      final attachmentId = attachMap['id'] as String;
      final localPath = p.join(targetImageDir, noteId, '$attachmentId$ext');

      // Write file to disk
      final destFile = File(localPath);
      destFile.parent.createSync(recursive: true);
      destFile.writeAsBytesSync(archiveFile.content as List<int>);

      // Create attachment with the new local path
      restoredAttachments.add(NoteAttachment(
        id: attachmentId,
        noteId: noteId,
        filePath: localPath,
        createdAt: attachMap['createdAt'] != null
            ? Utils.fromDateTimeString(attachMap['createdAt'] as String)
            : DateTime.now(),
        fileSize: (archiveFile.content as List<int>).length,
        remoteUrl: attachMap['remoteUrl'] as String?,
      ));
    }

    LogWrapper.logger.i(
      'ZipExportService: extracted ${exportData.data.length} diary days, '
      '${restoredAttachments.length} images',
    );

    return ZipImportResult(
      diaryDays: exportData.data,
      attachments: restoredAttachments,
      metadata: exportData.metadata,
    );
  }

  /// Checks whether [file] looks like a ZIP archive (magic bytes check).
  static bool isZipFile(File file) {
    try {
      final bytes = file.openSync()..setPositionSync(0);
      final header = bytes.readSync(4);
      bytes.closeSync();
      // ZIP magic bytes: PK\x03\x04
      return header.length >= 4 &&
          header[0] == 0x50 &&
          header[1] == 0x4B &&
          header[2] == 0x03 &&
          header[3] == 0x04;
    } catch (_) {
      return false;
    }
  }
}
