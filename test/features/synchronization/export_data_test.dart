import 'dart:convert';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportMetadata', () {
    test('toMap / fromMap round-trip', () {
      final metadata = ExportMetadata(
        username: 'testuser',
        salt: 'testsalt',
        exportDate: '2024-03-15T10:00:00.000',
        encrypted: true,
      );
      final map = metadata.toMap();
      final restored = ExportMetadata.fromMap(map);

      expect(restored.username, 'testuser');
      expect(restored.salt, 'testsalt');
      expect(restored.exportDate, '2024-03-15T10:00:00.000');
      expect(restored.encrypted, true);
    });

    test('toJson / fromJson round-trip', () {
      final metadata = ExportMetadata(
        username: 'user1',
        salt: null,
        exportDate: '2024-01-01T00:00:00.000',
        encrypted: false,
      );
      final jsonStr = metadata.toJson();
      final restored = ExportMetadata.fromJson(jsonStr);

      expect(restored.username, 'user1');
      expect(restored.salt, isNull);
      expect(restored.encrypted, false);
    });

    test('handles null username and salt', () {
      final metadata = ExportMetadata(
        exportDate: '2024-06-15T12:00:00.000',
        encrypted: false,
      );
      final map = metadata.toMap();
      expect(map['username'], isNull);
      expect(map['salt'], isNull);
    });
  });

  group('ExportData', () {
    List<DiaryDay> createSampleDiaryDays() {
      return [
        DiaryDay(
          day: DateTime(2024, 3, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 4),
            DayRating(dayRating: DayRatings.productivity, score: 3),
          ],
        ),
        DiaryDay(
          day: DateTime(2024, 3, 11),
          ratings: [
            DayRating(dayRating: DayRatings.sport, score: 5),
          ],
        ),
      ];
    }

    group('isNewFormat', () {
      test('detects new format with version and metadata', () {
        final jsonStr = jsonEncode({
          'version': '1.0',
          'metadata': {
            'exportDate': '2024-03-15',
            'encrypted': false,
          },
          'data': '[]',
        });
        expect(ExportData.isNewFormat(jsonStr), true);
      });

      test('detects legacy format (plain array)', () {
        final jsonStr = jsonEncode([
          {'day': '10.03.2024', 'ratings': [], 'notes': []},
        ]);
        expect(ExportData.isNewFormat(jsonStr), false);
      });

      test('returns false for invalid JSON', () {
        expect(ExportData.isNewFormat('not json'), false);
      });

      test('returns false for JSON without version key', () {
        final jsonStr = jsonEncode({
          'data': [],
        });
        expect(ExportData.isNewFormat(jsonStr), false);
      });

      test('returns false for JSON without metadata key', () {
        final jsonStr = jsonEncode({
          'version': '1.0',
          'data': [],
        });
        expect(ExportData.isNewFormat(jsonStr), false);
      });
    });

    group('fromMap / fromJson unencrypted', () {
      test('parses unencrypted data as list', () {
        final diaryDays = createSampleDiaryDays();
        final dataList = diaryDays.map((d) => d.toMap()).toList();

        final exportMap = {
          'version': '1.0',
          'metadata': {
            'username': 'testuser',
            'salt': null,
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': false,
          },
          'data': dataList,
        };

        final exportData = ExportData.fromMap(exportMap);
        expect(exportData.data.length, 2);
        expect(exportData.version, '1.0');
        expect(exportData.metadata.encrypted, false);
      });

      test('parses unencrypted data as JSON string', () {
        final diaryDays = createSampleDiaryDays();
        final dataJsonStr =
            jsonEncode(diaryDays.map((d) => d.toMap()).toList());

        final exportMap = {
          'version': '1.0',
          'metadata': {
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': false,
          },
          'data': dataJsonStr,
        };

        final exportData = ExportData.fromMap(exportMap);
        expect(exportData.data.length, 2);
      });

      test('fromJson parses full JSON string', () {
        final diaryDays = createSampleDiaryDays();
        final exportJsonStr = jsonEncode({
          'version': '1.0',
          'metadata': {
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': false,
          },
          'data': diaryDays.map((d) => d.toMap()).toList(),
        });

        final exportData = ExportData.fromJson(exportJsonStr);
        expect(exportData.data.length, 2);
        expect(
          Utils.toDate(exportData.data[0].day),
          Utils.toDate(DateTime(2024, 3, 10)),
        );
      });
    });

    group('fromMap / fromJson encrypted', () {
      test('decrypts data with correct password', () {
        const password = 'testPassword123';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        // Encrypt diary days data
        final diaryDays = createSampleDiaryDays();
        final plainDataJson =
            jsonEncode(diaryDays.map((d) => d.toMap()).toList());
        final encryptionKey =
            PasswordAuthService.getDatabaseEncryptionKey(password, salt);
        final encryptor = AesEncryptor(encryptionKey: encryptionKey);
        final encryptedData = encryptor.encryptStringAsBase64(plainDataJson);

        final exportMap = {
          'version': '1.0',
          'metadata': {
            'username': 'testuser',
            'salt': salt,
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': true,
          },
          'data': encryptedData,
        };

        final exportData = ExportData.fromMap(exportMap, password: password);
        expect(exportData.data.length, 2);
        expect(exportData.metadata.encrypted, true);
      });

      test('throws when password missing for encrypted data', () {
        final exportMap = {
          'version': '1.0',
          'metadata': {
            'salt': 'somesalt',
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': true,
          },
          'data': 'encryptedblob',
        };

        expect(
          () => ExportData.fromMap(exportMap),
          throwsException,
        );
      });

      test('throws when salt missing for encrypted data', () {
        final exportMap = {
          'version': '1.0',
          'metadata': {
            'salt': null,
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': true,
          },
          'data': 'encryptedblob',
        };

        expect(
          () => ExportData.fromMap(exportMap, password: 'pass'),
          throwsException,
        );
      });

      test('throws with wrong password', () {
        const password = 'correctPassword';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        final diaryDays = createSampleDiaryDays();
        final plainDataJson =
            jsonEncode(diaryDays.map((d) => d.toMap()).toList());
        final encryptionKey =
            PasswordAuthService.getDatabaseEncryptionKey(password, salt);
        final encryptor = AesEncryptor(encryptionKey: encryptionKey);
        final encryptedData = encryptor.encryptStringAsBase64(plainDataJson);

        final exportMap = {
          'version': '1.0',
          'metadata': {
            'salt': salt,
            'exportDate': '2024-03-15T10:00:00.000',
            'encrypted': true,
          },
          'data': encryptedData,
        };

        expect(
          () => ExportData.fromMap(exportMap, password: 'wrongPassword'),
          throwsException,
        );
      });
    });

    group('full export/import round-trip', () {
      test('unencrypted round-trip preserves data', () {
        final diaryDays = createSampleDiaryDays();
        final dataList = diaryDays.map((d) => d.toMap()).toList();

        final exportJsonStr = jsonEncode({
          'version': '1.0',
          'metadata': {
            'username': 'roundtrip_user',
            'salt': null,
            'exportDate': DateTime.now().toIso8601String(),
            'encrypted': false,
          },
          'data': dataList,
        });

        // Verify format detection
        expect(ExportData.isNewFormat(exportJsonStr), true);

        // Parse back
        final exportData = ExportData.fromJson(exportJsonStr);
        expect(exportData.data.length, diaryDays.length);
        expect(exportData.data[0].ratings.length,
            diaryDays[0].ratings.length);
        expect(exportData.data[0].ratings[0].score,
            diaryDays[0].ratings[0].score);
      });

      test('encrypted round-trip preserves data', () {
        const password = 'securePassword!@#';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        final diaryDays = createSampleDiaryDays();
        final plainDataJson =
            jsonEncode(diaryDays.map((d) => d.toMap()).toList());
        final encryptionKey =
            PasswordAuthService.getDatabaseEncryptionKey(password, salt);
        final encryptor = AesEncryptor(encryptionKey: encryptionKey);
        final encryptedData = encryptor.encryptStringAsBase64(plainDataJson);

        final exportJsonStr = jsonEncode({
          'version': '1.0',
          'metadata': {
            'username': 'encrypted_user',
            'salt': salt,
            'exportDate': DateTime.now().toIso8601String(),
            'encrypted': true,
          },
          'data': encryptedData,
        });

        // Verify format detection
        expect(ExportData.isNewFormat(exportJsonStr), true);

        // Parse back with password
        final exportData =
            ExportData.fromJson(exportJsonStr, password: password);
        expect(exportData.data.length, diaryDays.length);
        expect(exportData.metadata.encrypted, true);
        expect(exportData.metadata.username, 'encrypted_user');
      });
    });
  });
}
