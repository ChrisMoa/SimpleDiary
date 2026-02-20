import 'package:day_tracker/core/settings/backup_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupSettings', () {
    test('fromEmpty creates valid defaults', () {
      final settings = BackupSettings.fromEmpty();

      expect(settings.enabled, false);
      expect(settings.frequency, BackupFrequency.weekly);
      expect(settings.preferredTimeMinutes, 2 * 60);
      expect(settings.wifiOnly, true);
      expect(settings.maxBackups, 10);
      expect(settings.lastBackupTimestamp, isNull);
      expect(settings.backupDirectoryPath, isNull);
      expect(settings.destination, BackupDestination.localOnly);
      expect(settings.isCloudEnabled, false);
    });

    test('toMap serializes all fields', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 3 * 60,
        wifiOnly: false,
        maxBackups: 5,
        lastBackupTimestamp: '2026-02-20T10:00:00.000Z',
        backupDirectoryPath: '/tmp/backups',
        destination: BackupDestination.both,
      );

      final map = settings.toMap();

      expect(map['enabled'], true);
      expect(map['frequency'], 'daily');
      expect(map['preferredTimeMinutes'], 180);
      expect(map['wifiOnly'], false);
      expect(map['maxBackups'], 5);
      expect(map['lastBackupTimestamp'], '2026-02-20T10:00:00.000Z');
      expect(map['backupDirectoryPath'], '/tmp/backups');
      expect(map['destination'], 'both');
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'enabled': true,
        'frequency': 'monthly',
        'preferredTimeMinutes': 360,
        'wifiOnly': false,
        'maxBackups': 20,
        'lastBackupTimestamp': '2026-01-15T08:00:00.000Z',
        'backupDirectoryPath': '/custom/path',
        'destination': 'cloudOnly',
      };

      final settings = BackupSettings.fromMap(map);

      expect(settings.enabled, true);
      expect(settings.frequency, BackupFrequency.monthly);
      expect(settings.preferredTimeMinutes, 360);
      expect(settings.wifiOnly, false);
      expect(settings.maxBackups, 20);
      expect(settings.lastBackupTimestamp, '2026-01-15T08:00:00.000Z');
      expect(settings.backupDirectoryPath, '/custom/path');
      expect(settings.destination, BackupDestination.cloudOnly);
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};

      final settings = BackupSettings.fromMap(map);

      expect(settings.enabled, false);
      expect(settings.frequency, BackupFrequency.weekly);
      expect(settings.preferredTimeMinutes, 2 * 60);
      expect(settings.wifiOnly, true);
      expect(settings.maxBackups, 10);
      expect(settings.lastBackupTimestamp, isNull);
      expect(settings.backupDirectoryPath, isNull);
      expect(settings.destination, BackupDestination.localOnly);
    });

    test('fromMap backward compat: cloudSyncEnabled true maps to both', () {
      final map = {
        'enabled': true,
        'frequency': 'daily',
        'preferredTimeMinutes': 120,
        'wifiOnly': true,
        'maxBackups': 10,
        'cloudSyncEnabled': true,
      };

      final settings = BackupSettings.fromMap(map);
      expect(settings.destination, BackupDestination.both);
    });

    test('fromMap backward compat: cloudSyncEnabled false maps to localOnly', () {
      final map = {
        'cloudSyncEnabled': false,
      };

      final settings = BackupSettings.fromMap(map);
      expect(settings.destination, BackupDestination.localOnly);
    });

    test('fromMap prefers destination over cloudSyncEnabled', () {
      final map = {
        'destination': 'cloudOnly',
        'cloudSyncEnabled': false,
      };

      final settings = BackupSettings.fromMap(map);
      expect(settings.destination, BackupDestination.cloudOnly);
    });

    test('round-trip through JSON preserves data', () {
      final original = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 180,
        wifiOnly: false,
        maxBackups: 15,
        lastBackupTimestamp: '2026-02-20T10:00:00.000Z',
        backupDirectoryPath: '/test/path',
        destination: BackupDestination.both,
      );

      final json = original.toJson();
      final restored = BackupSettings.fromJson(json);

      expect(restored.enabled, original.enabled);
      expect(restored.frequency, original.frequency);
      expect(restored.preferredTimeMinutes, original.preferredTimeMinutes);
      expect(restored.wifiOnly, original.wifiOnly);
      expect(restored.maxBackups, original.maxBackups);
      expect(restored.lastBackupTimestamp, original.lastBackupTimestamp);
      expect(restored.backupDirectoryPath, original.backupDirectoryPath);
      expect(restored.destination, original.destination);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = BackupSettings.fromEmpty();

      final updated = original.copyWith(
        enabled: true,
        frequency: BackupFrequency.daily,
        maxBackups: 5,
      );

      expect(updated.enabled, true);
      expect(updated.frequency, BackupFrequency.daily);
      expect(updated.maxBackups, 5);
      expect(updated.wifiOnly, original.wifiOnly);
      expect(updated.preferredTimeMinutes, original.preferredTimeMinutes);
    });

    test('copyWith with no arguments creates identical copy', () {
      final original = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.monthly,
        preferredTimeMinutes: 300,
        wifiOnly: false,
        maxBackups: 7,
        lastBackupTimestamp: '2026-02-01T00:00:00.000Z',
      );

      final copy = original.copyWith();

      expect(copy.enabled, original.enabled);
      expect(copy.frequency, original.frequency);
      expect(copy.preferredTimeMinutes, original.preferredTimeMinutes);
      expect(copy.wifiOnly, original.wifiOnly);
      expect(copy.maxBackups, original.maxBackups);
      expect(copy.lastBackupTimestamp, original.lastBackupTimestamp);
    });

    test('preferredTime getter converts minutes to TimeOfDay', () {
      final settings = BackupSettings.fromEmpty();
      settings.preferredTimeMinutes = 14 * 60 + 30; // 14:30

      expect(settings.preferredTime, const TimeOfDay(hour: 14, minute: 30));
    });

    test('preferredTime setter converts TimeOfDay to minutes', () {
      final settings = BackupSettings.fromEmpty();
      settings.preferredTime = const TimeOfDay(hour: 8, minute: 15);

      expect(settings.preferredTimeMinutes, 8 * 60 + 15);
    });

    test('lastBackupDateTime parses ISO timestamp', () {
      final settings = BackupSettings.fromEmpty();
      settings.lastBackupTimestamp = '2026-02-20T10:30:00.000Z';

      final dt = settings.lastBackupDateTime;
      expect(dt, isNotNull);
      expect(dt!.year, 2026);
      expect(dt.month, 2);
      expect(dt.day, 20);
    });

    test('lastBackupDateTime returns null when no timestamp', () {
      final settings = BackupSettings.fromEmpty();
      expect(settings.lastBackupDateTime, isNull);
    });

    test('isBackupOverdue returns true when never backed up and enabled', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
      );

      expect(settings.isBackupOverdue, true);
    });

    test('isBackupOverdue returns false when disabled', () {
      final settings = BackupSettings(
        enabled: false,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
      );

      expect(settings.isBackupOverdue, false);
    });

    test('isBackupOverdue daily returns true after 24 hours', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
        lastBackupTimestamp:
            DateTime.now().subtract(const Duration(hours: 25)).toIso8601String(),
      );

      expect(settings.isBackupOverdue, true);
    });

    test('isBackupOverdue daily returns false within 24 hours', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.daily,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
        lastBackupTimestamp:
            DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      );

      expect(settings.isBackupOverdue, false);
    });

    test('isBackupOverdue weekly returns true after 7 days', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.weekly,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
        lastBackupTimestamp:
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      );

      expect(settings.isBackupOverdue, true);
    });

    test('isBackupOverdue monthly returns true after 30 days', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.monthly,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
        lastBackupTimestamp:
            DateTime.now().subtract(const Duration(days: 31)).toIso8601String(),
      );

      expect(settings.isBackupOverdue, true);
    });

    test('toString contains key fields', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.weekly,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
      );

      final str = settings.toString();
      expect(str, contains('enabled: true'));
      expect(str, contains('frequency: weekly'));
      expect(str, contains('maxBackups: 10'));
    });

    test('copyWith updates destination', () {
      final original = BackupSettings.fromEmpty();
      expect(original.destination, BackupDestination.localOnly);

      final updated = original.copyWith(destination: BackupDestination.both);
      expect(updated.destination, BackupDestination.both);
      expect(updated.enabled, original.enabled);
    });

    test('toString contains destination field', () {
      final settings = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.weekly,
        preferredTimeMinutes: 120,
        wifiOnly: true,
        maxBackups: 10,
        destination: BackupDestination.cloudOnly,
      );

      expect(settings.toString(), contains('destination: cloudOnly'));
    });

    test('isCloudEnabled returns correct values for each destination', () {
      final local = BackupSettings.fromEmpty();
      expect(local.isCloudEnabled, false);

      final cloud = local.copyWith(destination: BackupDestination.cloudOnly);
      expect(cloud.isCloudEnabled, true);

      final both = local.copyWith(destination: BackupDestination.both);
      expect(both.isCloudEnabled, true);
    });
  });

  group('BackupFrequency', () {
    test('toJson returns name string', () {
      expect(BackupFrequency.daily.toJson(), 'daily');
      expect(BackupFrequency.weekly.toJson(), 'weekly');
      expect(BackupFrequency.monthly.toJson(), 'monthly');
    });

    test('fromJson parses valid names', () {
      expect(BackupFrequency.fromJson('daily'), BackupFrequency.daily);
      expect(BackupFrequency.fromJson('weekly'), BackupFrequency.weekly);
      expect(BackupFrequency.fromJson('monthly'), BackupFrequency.monthly);
    });

    test('fromJson falls back to weekly for unknown values', () {
      expect(BackupFrequency.fromJson('unknown'), BackupFrequency.weekly);
      expect(BackupFrequency.fromJson(''), BackupFrequency.weekly);
    });
  });

  group('BackupDestination', () {
    test('toJson returns name string', () {
      expect(BackupDestination.localOnly.toJson(), 'localOnly');
      expect(BackupDestination.cloudOnly.toJson(), 'cloudOnly');
      expect(BackupDestination.both.toJson(), 'both');
    });

    test('fromJson parses valid names', () {
      expect(BackupDestination.fromJson('localOnly'), BackupDestination.localOnly);
      expect(BackupDestination.fromJson('cloudOnly'), BackupDestination.cloudOnly);
      expect(BackupDestination.fromJson('both'), BackupDestination.both);
    });

    test('fromJson falls back to localOnly for unknown values', () {
      expect(BackupDestination.fromJson('unknown'), BackupDestination.localOnly);
      expect(BackupDestination.fromJson(''), BackupDestination.localOnly);
    });
  });
}
