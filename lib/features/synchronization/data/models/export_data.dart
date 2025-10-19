import 'dart:convert';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';

/// Model for export data with metadata
/// This format allows storing encryption metadata alongside the diary data
class ExportData {
  final String version;
  final ExportMetadata metadata;
  final List<DiaryDay> data;

  ExportData({
    required this.version,
    required this.metadata,
    required this.data,
  });

  /// Create ExportData from map, handling both encrypted and unencrypted data
  /// [password] - Required if data is encrypted
  factory ExportData.fromMap(Map<String, dynamic> map, {String? password}) {
    final metadata = ExportMetadata.fromMap(map['metadata'] as Map<String, dynamic>);
    
    List<DiaryDay> diaryDays;
    final dataField = map['data'];
    
    if (metadata.encrypted) {
      // Data is encrypted as a base64 string
      if (password == null || metadata.salt == null) {
        throw Exception('Password and salt required for encrypted data');
      }
      
      String encryptedData = dataField as String;
      String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(password, metadata.salt!);
      var decryptor = AesEncryptor(encryptionKey: encryptionKey);
      
      try {
        String decryptedJson = decryptor.decryptStringFromBase64(encryptedData);
        List<dynamic> jsonList = json.decode(decryptedJson);
        diaryDays = jsonList.map((item) => DiaryDay.fromMap(item as Map<String, dynamic>)).toList();
      } catch (e) {
        throw Exception('Failed to decrypt data. Wrong password or corrupted file. Details: $e');
      }
    } else {
      // Data is plain JSON - can be either string or list
      if (dataField is String) {
        // Data stored as JSON string
        List<dynamic> jsonList = json.decode(dataField);
        diaryDays = jsonList.map((item) => DiaryDay.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        // Data stored as list directly
        diaryDays = (dataField as List<dynamic>)
            .map((item) => DiaryDay.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    }
    
    return ExportData(
      version: map['version'] as String,
      metadata: metadata,
      data: diaryDays,
    );
  }

  /// Create ExportData from JSON string
  /// [password] - Required if data is encrypted
  factory ExportData.fromJson(String source, {String? password}) =>
      ExportData.fromMap(json.decode(source) as Map<String, dynamic>, password: password);

  /// Check if a JSON string is in the new export format (with metadata)
  static bool isNewFormat(String jsonString) {
    try {
      final Map<String, dynamic> map = json.decode(jsonString);
      return map.containsKey('version') && map.containsKey('metadata');
    } catch (e) {
      return false;
    }
  }
}

/// Metadata for export files
class ExportMetadata {
  final String? username;
  final String? salt;
  final String exportDate;
  final bool encrypted;

  ExportMetadata({
    this.username,
    this.salt,
    required this.exportDate,
    required this.encrypted,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'salt': salt,
      'exportDate': exportDate,
      'encrypted': encrypted,
    };
  }

  factory ExportMetadata.fromMap(Map<String, dynamic> map) {
    return ExportMetadata(
      username: map['username'] as String?,
      salt: map['salt'] as String?,
      exportDate: map['exportDate'] as String,
      encrypted: map['encrypted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExportMetadata.fromJson(String source) =>
      ExportMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}
