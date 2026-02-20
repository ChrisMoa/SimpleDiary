import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupMetadata', () {
    BackupMetadata createSample({String? error}) {
      return BackupMetadata(
        id: 'backup_2026-02-20T10-00-00',
        createdAt: DateTime(2026, 2, 20, 10, 0, 0),
        sizeBytes: 1536,
        filePath: '/tmp/backups/backup_2026-02-20T10-00-00.json',
        type: BackupType.manual,
        diaryDayCount: 30,
        noteCount: 50,
        habitCount: 5,
        habitEntryCount: 120,
        error: error,
      );
    }

    test('isSuccessful returns true when no error', () {
      final metadata = createSample();
      expect(metadata.isSuccessful, true);
    });

    test('isSuccessful returns false when error is set', () {
      final metadata = createSample(error: 'Disk full');
      expect(metadata.isSuccessful, false);
    });

    test('formattedSize formats bytes correctly', () {
      expect(
        BackupMetadata(
          id: 'test',
          createdAt: DateTime.now(),
          sizeBytes: 500,
          filePath: '/tmp/test.json',
          type: BackupType.manual,
          diaryDayCount: 0,
          noteCount: 0,
          habitCount: 0,
          habitEntryCount: 0,
        ).formattedSize,
        '500 B',
      );
    });

    test('formattedSize formats kilobytes correctly', () {
      expect(
        BackupMetadata(
          id: 'test',
          createdAt: DateTime.now(),
          sizeBytes: 2048,
          filePath: '/tmp/test.json',
          type: BackupType.manual,
          diaryDayCount: 0,
          noteCount: 0,
          habitCount: 0,
          habitEntryCount: 0,
        ).formattedSize,
        '2.0 KB',
      );
    });

    test('formattedSize formats megabytes correctly', () {
      expect(
        BackupMetadata(
          id: 'test',
          createdAt: DateTime.now(),
          sizeBytes: 1048576,
          filePath: '/tmp/test.json',
          type: BackupType.manual,
          diaryDayCount: 0,
          noteCount: 0,
          habitCount: 0,
          habitEntryCount: 0,
        ).formattedSize,
        '1.0 MB',
      );
    });

    test('toMap serializes all fields', () {
      final metadata = createSample();
      final map = metadata.toMap();

      expect(map['id'], 'backup_2026-02-20T10-00-00');
      expect(map['createdAt'], '2026-02-20T10:00:00.000');
      expect(map['sizeBytes'], 1536);
      expect(map['filePath'], '/tmp/backups/backup_2026-02-20T10-00-00.json');
      expect(map['type'], 'manual');
      expect(map['diaryDayCount'], 30);
      expect(map['noteCount'], 50);
      expect(map['habitCount'], 5);
      expect(map['habitEntryCount'], 120);
      expect(map['error'], isNull);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'id': 'backup_test',
        'createdAt': '2026-02-20T10:00:00.000',
        'sizeBytes': 2048,
        'filePath': '/tmp/test.json',
        'type': 'scheduled',
        'diaryDayCount': 10,
        'noteCount': 20,
        'habitCount': 3,
        'habitEntryCount': 50,
        'error': null,
      };

      final metadata = BackupMetadata.fromMap(map);

      expect(metadata.id, 'backup_test');
      expect(metadata.createdAt, DateTime(2026, 2, 20, 10, 0, 0));
      expect(metadata.sizeBytes, 2048);
      expect(metadata.filePath, '/tmp/test.json');
      expect(metadata.type, BackupType.scheduled);
      expect(metadata.diaryDayCount, 10);
      expect(metadata.noteCount, 20);
      expect(metadata.habitCount, 3);
      expect(metadata.habitEntryCount, 50);
      expect(metadata.error, isNull);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'backup_test',
        'createdAt': '2026-02-20T10:00:00.000',
        'filePath': '/tmp/test.json',
      };

      final metadata = BackupMetadata.fromMap(map);

      expect(metadata.sizeBytes, 0);
      expect(metadata.type, BackupType.manual);
      expect(metadata.diaryDayCount, 0);
      expect(metadata.noteCount, 0);
      expect(metadata.habitCount, 0);
      expect(metadata.habitEntryCount, 0);
    });

    test('round-trip through JSON preserves data', () {
      final original = createSample();
      final json = original.toJson();
      final restored = BackupMetadata.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.createdAt, original.createdAt);
      expect(restored.sizeBytes, original.sizeBytes);
      expect(restored.filePath, original.filePath);
      expect(restored.type, original.type);
      expect(restored.diaryDayCount, original.diaryDayCount);
      expect(restored.noteCount, original.noteCount);
      expect(restored.habitCount, original.habitCount);
      expect(restored.habitEntryCount, original.habitEntryCount);
      expect(restored.error, original.error);
    });

    test('round-trip preserves error field', () {
      final original = createSample(error: 'Something went wrong');
      final json = original.toJson();
      final restored = BackupMetadata.fromJson(json);

      expect(restored.error, 'Something went wrong');
      expect(restored.isSuccessful, false);
    });

    test('toString contains key fields', () {
      final metadata = createSample();
      final str = metadata.toString();

      expect(str, contains('backup_2026-02-20T10-00-00'));
      expect(str, contains('manual'));
      expect(str, contains('days: 30'));
      expect(str, contains('notes: 50'));
      expect(str, contains('habits: 5'));
    });
  });

  group('BackupType', () {
    test('toJson returns name string', () {
      expect(BackupType.manual.toJson(), 'manual');
      expect(BackupType.scheduled.toJson(), 'scheduled');
      expect(BackupType.preRestore.toJson(), 'preRestore');
    });

    test('fromJson parses valid names', () {
      expect(BackupType.fromJson('manual'), BackupType.manual);
      expect(BackupType.fromJson('scheduled'), BackupType.scheduled);
      expect(BackupType.fromJson('preRestore'), BackupType.preRestore);
    });

    test('fromJson falls back to manual for unknown values', () {
      expect(BackupType.fromJson('unknown'), BackupType.manual);
      expect(BackupType.fromJson(''), BackupType.manual);
    });
  });
}
