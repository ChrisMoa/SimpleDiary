import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileDbProvider extends StateNotifier<List<DiaryDay>> {
  FileDbProvider() : super([]) {}

  /// Export diary days to file (legacy format without metadata)
  /// This is kept for backward compatibility but should not be used for new exports
  @Deprecated('Use exportWithMetadata instead')
  Future<void> export(List<DiaryDay> diaryDays, File file) async {
    LogWrapper.logger.i('export started (legacy format)');
    List<Map<String, dynamic>> jsonList =
        diaryDays.map((obj) => obj.toMap()).toList();

    // Convert the list of maps to a JSON string
    String jsonString = jsonEncode(jsonList);

    // Write the JSON string to a file
    file.writeAsStringSync(jsonString);

    LogWrapper.logger.i('JSON file written successfully.');
  }

  /// Export diary days with metadata (new format)
  /// [diaryDays] - List of diary days to export
  /// [file] - Target file for export
  /// [username] - Optional username for metadata
  /// [salt] - Optional salt for encryption (should be provided if data will be encrypted)
  /// [encrypted] - Whether the data will be encrypted
  /// [password] - Password for encryption (required if encrypted is true)
  Future<void> exportWithMetadata({
    required List<DiaryDay> diaryDays,
    required File file,
    String? username,
    String? salt,
    required bool encrypted,
    String? password,
  }) async {
    LogWrapper.logger.i('export started (new format with metadata)');

    // Encrypt data if password is provided
    String dataJson;
    if (encrypted && password != null && salt != null) {
      // Encrypt only the diary days data
      String plainDataJson = jsonEncode(diaryDays.map((d) => d.toMap()).toList());
      String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(password, salt);
      var encryptor = AesEncryptor(encryptionKey: encryptionKey);
      dataJson = encryptor.encryptStringAsBase64(plainDataJson);
      LogWrapper.logger.i('Data encrypted (${plainDataJson.length} -> ${dataJson.length} chars)');
    } else {
      // Store data as plain JSON array
      dataJson = jsonEncode(diaryDays.map((d) => d.toMap()).toList());
    }

    // Create export structure with metadata in plain text
    final exportMap = {
      'version': '1.0',
      'metadata': {
        'username': username,
        'salt': salt,
        'exportDate': DateTime.now().toIso8601String(),
        'encrypted': encrypted,
      },
      'data': dataJson, // This is either encrypted string or plain JSON
    };

    // Write to file
    String jsonString = jsonEncode(exportMap);
    file.writeAsStringSync(jsonString);

    LogWrapper.logger.i('JSON file with metadata written successfully.');
  }

  /// Import diary days from file with automatic format detection
  /// Supports both legacy format (plain array) and new format (with metadata)
  /// [password] - Required if file is encrypted
  /// Returns the metadata if available, null otherwise
  Future<ExportMetadata?> import(File file, {String? password}) async {
    LogWrapper.logger.t("import started");
    state = [];

    // Read the contents of the JSON file
    String jsonString = file.readAsStringSync();

    ExportMetadata? metadata;
    List<DiaryDay> diaryDays;

    // Check if it's the new format with metadata
    if (ExportData.isNewFormat(jsonString)) {
      LogWrapper.logger.i('Detected new export format with metadata');
      final exportData = ExportData.fromJson(jsonString, password: password);
      metadata = exportData.metadata;
      diaryDays = exportData.data;
      LogWrapper.logger.i(
          'Import metadata: encrypted=${metadata.encrypted}, salt=${metadata.salt != null ? "present" : "missing"}');
    } else {
      LogWrapper.logger
          .w('Detected legacy export format without metadata');
      // Legacy format: plain array of diary days
      List<dynamic> jsonList = jsonDecode(jsonString);
      diaryDays = jsonList.map((json) => DiaryDay.fromMap(json)).toList();
    }

    state = [...diaryDays];
    LogWrapper.logger.t("import finished");

    return metadata;
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final fileDbStateProvider =
    StateNotifierProvider<FileDbProvider, List<DiaryDay>>((ref) {
  return FileDbProvider();
});
