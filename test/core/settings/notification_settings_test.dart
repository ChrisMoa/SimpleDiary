import 'package:day_tracker/core/settings/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSettings', () {
    test('fromEmpty creates valid defaults', () {
      final settings = NotificationSettings.fromEmpty();

      expect(settings.enabled, false);
      expect(settings.reminderTimeMinutes, 20 * 60); // 20:00
      expect(settings.smartRemindersEnabled, true);
      expect(settings.streakWarningsEnabled, true);
      expect(settings.reminderDays, isEmpty);
      expect(settings.maxSmartRemindersPerDay, 3);
      expect(settings.quietHoursStartMinutes, 22 * 60);
      expect(settings.quietHoursEndMinutes, 8 * 60);
    });

    test('reminderTime getter converts minutes correctly', () {
      final settings = NotificationSettings.fromEmpty();
      settings.reminderTimeMinutes = 14 * 60 + 30; // 14:30

      final time = settings.reminderTime;
      expect(time.hour, 14);
      expect(time.minute, 30);
    });

    test('reminderTime setter converts TimeOfDay correctly', () {
      final settings = NotificationSettings.fromEmpty();
      settings.reminderTime = const TimeOfDay(hour: 9, minute: 15);

      expect(settings.reminderTimeMinutes, 9 * 60 + 15);
    });

    test('quietHoursStart getter converts minutes correctly', () {
      final settings = NotificationSettings.fromEmpty();

      final time = settings.quietHoursStart;
      expect(time.hour, 22);
      expect(time.minute, 0);
    });

    test('quietHoursStart setter converts TimeOfDay correctly', () {
      final settings = NotificationSettings.fromEmpty();
      settings.quietHoursStart = const TimeOfDay(hour: 23, minute: 30);

      expect(settings.quietHoursStartMinutes, 23 * 60 + 30);
    });

    test('quietHoursEnd getter converts minutes correctly', () {
      final settings = NotificationSettings.fromEmpty();

      final time = settings.quietHoursEnd;
      expect(time.hour, 8);
      expect(time.minute, 0);
    });

    test('quietHoursEnd setter converts TimeOfDay correctly', () {
      final settings = NotificationSettings.fromEmpty();
      settings.quietHoursEnd = const TimeOfDay(hour: 7, minute: 45);

      expect(settings.quietHoursEndMinutes, 7 * 60 + 45);
    });

    test('toMap serializes all fields', () {
      final settings = NotificationSettings(
        enabled: true,
        reminderTimeMinutes: 12 * 60 + 45,
        smartRemindersEnabled: false,
        streakWarningsEnabled: true,
        reminderDays: [1, 3, 5],
        maxSmartRemindersPerDay: 5,
        quietHoursStartMinutes: 23 * 60,
        quietHoursEndMinutes: 7 * 60,
      );

      final map = settings.toMap();

      expect(map['enabled'], true);
      expect(map['reminderTimeMinutes'], 12 * 60 + 45);
      expect(map['smartRemindersEnabled'], false);
      expect(map['streakWarningsEnabled'], true);
      expect(map['reminderDays'], [1, 3, 5]);
      expect(map['maxSmartRemindersPerDay'], 5);
      expect(map['quietHoursStartMinutes'], 23 * 60);
      expect(map['quietHoursEndMinutes'], 7 * 60);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'enabled': true,
        'reminderTimeMinutes': 18 * 60 + 30,
        'smartRemindersEnabled': false,
        'streakWarningsEnabled': true,
        'reminderDays': [2, 4, 6],
        'maxSmartRemindersPerDay': 2,
        'quietHoursStartMinutes': 21 * 60,
        'quietHoursEndMinutes': 9 * 60,
      };

      final settings = NotificationSettings.fromMap(map);

      expect(settings.enabled, true);
      expect(settings.reminderTimeMinutes, 18 * 60 + 30);
      expect(settings.smartRemindersEnabled, false);
      expect(settings.streakWarningsEnabled, true);
      expect(settings.reminderDays, [2, 4, 6]);
      expect(settings.maxSmartRemindersPerDay, 2);
      expect(settings.quietHoursStartMinutes, 21 * 60);
      expect(settings.quietHoursEndMinutes, 9 * 60);
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};

      final settings = NotificationSettings.fromMap(map);

      expect(settings.enabled, false);
      expect(settings.reminderTimeMinutes, 20 * 60);
      expect(settings.smartRemindersEnabled, true);
      expect(settings.streakWarningsEnabled, true);
      expect(settings.reminderDays, isEmpty);
      expect(settings.maxSmartRemindersPerDay, 3);
      expect(settings.quietHoursStartMinutes, 22 * 60);
      expect(settings.quietHoursEndMinutes, 8 * 60);
    });

    test('fromMap handles missing new fields with defaults (backward compat)', () {
      // Simulate settings saved before the new fields were added
      final map = {
        'enabled': true,
        'reminderTimeMinutes': 15 * 60,
        'smartRemindersEnabled': true,
        'streakWarningsEnabled': true,
        'reminderDays': <int>[],
      };

      final settings = NotificationSettings.fromMap(map);

      expect(settings.maxSmartRemindersPerDay, 3);
      expect(settings.quietHoursStartMinutes, 22 * 60);
      expect(settings.quietHoursEndMinutes, 8 * 60);
    });

    test('round-trip through JSON preserves data', () {
      final original = NotificationSettings(
        enabled: true,
        reminderTimeMinutes: 15 * 60,
        smartRemindersEnabled: true,
        streakWarningsEnabled: false,
        reminderDays: [1, 2, 3, 4, 5],
        maxSmartRemindersPerDay: 4,
        quietHoursStartMinutes: 23 * 60 + 30,
        quietHoursEndMinutes: 6 * 60 + 45,
      );

      final json = original.toJson();
      final restored = NotificationSettings.fromJson(json);

      expect(restored.enabled, original.enabled);
      expect(restored.reminderTimeMinutes, original.reminderTimeMinutes);
      expect(restored.smartRemindersEnabled, original.smartRemindersEnabled);
      expect(restored.streakWarningsEnabled, original.streakWarningsEnabled);
      expect(restored.reminderDays, original.reminderDays);
      expect(restored.maxSmartRemindersPerDay, original.maxSmartRemindersPerDay);
      expect(restored.quietHoursStartMinutes, original.quietHoursStartMinutes);
      expect(restored.quietHoursEndMinutes, original.quietHoursEndMinutes);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = NotificationSettings.fromEmpty();

      final updated = original.copyWith(
        enabled: true,
        reminderTimeMinutes: 8 * 60,
      );

      expect(updated.enabled, true);
      expect(updated.reminderTimeMinutes, 8 * 60);
      expect(updated.smartRemindersEnabled, original.smartRemindersEnabled);
      expect(updated.streakWarningsEnabled, original.streakWarningsEnabled);
      expect(updated.reminderDays, original.reminderDays);
      expect(updated.maxSmartRemindersPerDay, original.maxSmartRemindersPerDay);
      expect(updated.quietHoursStartMinutes, original.quietHoursStartMinutes);
      expect(updated.quietHoursEndMinutes, original.quietHoursEndMinutes);
    });

    test('copyWith updates new fields', () {
      final original = NotificationSettings.fromEmpty();

      final updated = original.copyWith(
        maxSmartRemindersPerDay: 5,
        quietHoursStartMinutes: 21 * 60,
        quietHoursEndMinutes: 9 * 60,
      );

      expect(updated.maxSmartRemindersPerDay, 5);
      expect(updated.quietHoursStartMinutes, 21 * 60);
      expect(updated.quietHoursEndMinutes, 9 * 60);
      // Original fields unchanged
      expect(updated.enabled, original.enabled);
      expect(updated.reminderTimeMinutes, original.reminderTimeMinutes);
    });

    test('copyWith with no arguments creates identical copy', () {
      final original = NotificationSettings(
        enabled: true,
        reminderTimeMinutes: 10 * 60,
        smartRemindersEnabled: false,
        streakWarningsEnabled: true,
        reminderDays: [1, 7],
        maxSmartRemindersPerDay: 2,
        quietHoursStartMinutes: 23 * 60,
        quietHoursEndMinutes: 7 * 60,
      );

      final copy = original.copyWith();

      expect(copy.enabled, original.enabled);
      expect(copy.reminderTimeMinutes, original.reminderTimeMinutes);
      expect(copy.smartRemindersEnabled, original.smartRemindersEnabled);
      expect(copy.streakWarningsEnabled, original.streakWarningsEnabled);
      expect(copy.reminderDays, original.reminderDays);
      expect(copy.maxSmartRemindersPerDay, original.maxSmartRemindersPerDay);
      expect(copy.quietHoursStartMinutes, original.quietHoursStartMinutes);
      expect(copy.quietHoursEndMinutes, original.quietHoursEndMinutes);
    });

    test('toString formats time and quiet hours correctly', () {
      final settings = NotificationSettings.fromEmpty();
      settings.reminderTimeMinutes = 9 * 60 + 5; // 09:05

      final str = settings.toString();

      expect(str, contains('09:05'));
      expect(str, contains('enabled: false'));
      expect(str, contains('smartReminders: true'));
      expect(str, contains('streakWarnings: true'));
      expect(str, contains('maxSmartReminders: 3'));
      expect(str, contains('quietHours: 22:00-08:00'));
    });

    test('reminderDays list is independent between instances', () {
      final settings1 = NotificationSettings.fromEmpty();
      final settings2 = NotificationSettings.fromEmpty();

      settings1.reminderDays.add(1);

      expect(settings1.reminderDays, [1]);
      expect(settings2.reminderDays, isEmpty);
    });

    test('map contains all required keys', () {
      final settings = NotificationSettings.fromEmpty();
      final map = settings.toMap();

      expect(map.keys, containsAll([
        'enabled',
        'reminderTimeMinutes',
        'smartRemindersEnabled',
        'streakWarningsEnabled',
        'reminderDays',
        'maxSmartRemindersPerDay',
        'quietHoursStartMinutes',
        'quietHoursEndMinutes',
      ]));
    });
  });
}
