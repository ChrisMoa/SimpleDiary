import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FileDbProvider provider;
  late Directory tempDir;

  setUp(() {
    provider = FileDbProvider();
    tempDir = Directory.systemTemp.createTempSync('file_db_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

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
          DayRating(dayRating: DayRatings.food, score: 2),
        ],
      ),
    ];
  }

  group('FileDbProvider', () {
    group('exportToString', () {
      test('produces valid JSON with metadata (unencrypted)', () {
        final diaryDays = createSampleDiaryDays();
        final result = provider.exportToString(
          diaryDays: diaryDays,
          username: 'testuser',
          encrypted: false,
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        expect(decoded['version'], '1.0');
        expect(decoded['metadata']['encrypted'], false);
        expect(decoded['metadata']['username'], 'testuser');
        expect(decoded['data'], isNotNull);

        // Verify it's detected as new format
        expect(ExportData.isNewFormat(result), true);
      });

      test('produces encrypted data when password provided', () {
        final hashResult = PasswordAuthService.hashPassword('password');
        final salt = hashResult['salt']!;
        final diaryDays = createSampleDiaryDays();

        final result = provider.exportToString(
          diaryDays: diaryDays,
          username: 'testuser',
          salt: salt,
          encrypted: true,
          password: 'password',
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        expect(decoded['metadata']['encrypted'], true);
        expect(decoded['metadata']['salt'], salt);

        // Data should be a base64 string, not a JSON array
        final data = decoded['data'];
        expect(data, isA<String>());
        // Should be decodable as base64
        expect(() => base64.decode(data), returnsNormally);
      });

      test('unencrypted data can be parsed back', () {
        final diaryDays = createSampleDiaryDays();
        final result = provider.exportToString(
          diaryDays: diaryDays,
          encrypted: false,
        );

        final exportData = ExportData.fromJson(result);
        expect(exportData.data.length, 2);
        expect(Utils.toDate(exportData.data[0].day),
            Utils.toDate(DateTime(2024, 3, 10)));
      });

      test('encrypted data can be parsed back with password', () {
        const password = 'myPassword';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final diaryDays = createSampleDiaryDays();

        final result = provider.exportToString(
          diaryDays: diaryDays,
          salt: salt,
          encrypted: true,
          password: password,
        );

        final exportData = ExportData.fromJson(result, password: password);
        expect(exportData.data.length, 2);
        expect(exportData.metadata.encrypted, true);
      });
    });

    group('exportWithMetadata + import round-trip', () {
      test('unencrypted file round-trip', () async {
        final file = File('${tempDir.path}/test_export.json');
        final diaryDays = createSampleDiaryDays();

        // Export
        await provider.exportWithMetadata(
          diaryDays: diaryDays,
          file: file,
          username: 'roundtrip_user',
          encrypted: false,
        );

        expect(file.existsSync(), true);

        // Import
        final metadata = await provider.import(file);
        expect(metadata, isNotNull);
        expect(metadata!.encrypted, false);
        expect(metadata.username, 'roundtrip_user');
      });

      test('encrypted file round-trip', () async {
        const password = 'encryptedRoundTrip';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final file = File('${tempDir.path}/test_encrypted.json');
        final diaryDays = createSampleDiaryDays();

        // Export
        await provider.exportWithMetadata(
          diaryDays: diaryDays,
          file: file,
          username: 'encrypted_user',
          salt: salt,
          encrypted: true,
          password: password,
        );

        expect(file.existsSync(), true);

        // Import
        final metadata =
            await provider.import(file, password: password);
        expect(metadata, isNotNull);
        expect(metadata!.encrypted, true);
      });
    });

    group('import legacy format', () {
      test('imports legacy format (plain JSON array)', () async {
        final diaryDays = createSampleDiaryDays();
        final jsonList = diaryDays.map((d) => d.toMap()).toList();
        final jsonString = jsonEncode(jsonList);

        final file = File('${tempDir.path}/legacy.json');
        file.writeAsStringSync(jsonString);

        // Import - should detect legacy format
        final metadata = await provider.import(file);
        expect(metadata, isNull); // No metadata in legacy format
      });
    });

    group('export empty data', () {
      test('exports empty diary days list', () {
        final result = provider.exportToString(
          diaryDays: [],
          encrypted: false,
        );

        final exportData = ExportData.fromJson(result);
        expect(exportData.data, isEmpty);
      });
    });
  });
}
