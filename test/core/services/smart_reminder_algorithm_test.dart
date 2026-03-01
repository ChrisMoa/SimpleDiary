import 'package:day_tracker/core/services/smart_reminder_algorithm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartReminderAlgorithm', () {
    group('shouldSendReminder', () {
      test('returns false when entry exists for today', () {
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 14, 0),
          hasEntryToday: true,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });

      test('returns false when max reminders reached', () {
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 14, 0),
          hasEntryToday: false,
          remindersSentToday: 3,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });

      test('returns false during quiet hours (midnight-crossing)', () {
        // 23:00 is within 22:00–08:00 quiet hours
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 23, 0),
          hasEntryToday: false,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });

      test('returns false during quiet hours (early morning)', () {
        // 06:00 is within 22:00–08:00 quiet hours
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 6, 0),
          hasEntryToday: false,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });

      test('returns true when all conditions are met', () {
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 14, 0),
          hasEntryToday: false,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, true);
      });

      test('returns true when some reminders sent but below max', () {
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 15, 0),
          hasEntryToday: false,
          remindersSentToday: 2,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, true);
      });

      test('returns true at boundary just after quiet hours end', () {
        // 08:00 is exactly the end — should NOT be in quiet hours
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 8, 0),
          hasEntryToday: false,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, true);
      });

      test('returns false at boundary exactly at quiet hours start', () {
        // 22:00 is exactly the start — should be in quiet hours
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 22, 0),
          hasEntryToday: false,
          remindersSentToday: 0,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });

      test('returns false when max is exceeded', () {
        final result = SmartReminderAlgorithm.shouldSendReminder(
          now: DateTime(2026, 3, 1, 14, 0),
          hasEntryToday: false,
          remindersSentToday: 5,
          maxRemindersPerDay: 3,
          quietHoursStartMinutes: 22 * 60,
          quietHoursEndMinutes: 8 * 60,
        );
        expect(result, false);
      });
    });

    group('calculateIntensity', () {
      test('returns gentle when 0 reminders sent', () {
        expect(
          SmartReminderAlgorithm.calculateIntensity(0),
          ReminderIntensity.gentle,
        );
      });

      test('returns gentle for negative count', () {
        expect(
          SmartReminderAlgorithm.calculateIntensity(-1),
          ReminderIntensity.gentle,
        );
      });

      test('returns normal when 1 reminder sent', () {
        expect(
          SmartReminderAlgorithm.calculateIntensity(1),
          ReminderIntensity.normal,
        );
      });

      test('returns urgent when 2 reminders sent', () {
        expect(
          SmartReminderAlgorithm.calculateIntensity(2),
          ReminderIntensity.urgent,
        );
      });

      test('returns urgent when many reminders sent', () {
        expect(
          SmartReminderAlgorithm.calculateIntensity(10),
          ReminderIntensity.urgent,
        );
      });
    });

    group('isInQuietHours', () {
      test('midnight-crossing range: time after start', () {
        // 23:00 is in 22:00–08:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(23 * 60, 22 * 60, 8 * 60),
          true,
        );
      });

      test('midnight-crossing range: time before end', () {
        // 03:00 is in 22:00–08:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(3 * 60, 22 * 60, 8 * 60),
          true,
        );
      });

      test('midnight-crossing range: time outside', () {
        // 14:00 is NOT in 22:00–08:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(14 * 60, 22 * 60, 8 * 60),
          false,
        );
      });

      test('same-day range: time inside', () {
        // 14:00 is in 13:00–17:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(14 * 60, 13 * 60, 17 * 60),
          true,
        );
      });

      test('same-day range: time outside', () {
        // 18:00 is NOT in 13:00–17:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(18 * 60, 13 * 60, 17 * 60),
          false,
        );
      });

      test('same-day range: exactly at start', () {
        // 13:00 is in 13:00–17:00 (start is inclusive)
        expect(
          SmartReminderAlgorithm.isInQuietHours(13 * 60, 13 * 60, 17 * 60),
          true,
        );
      });

      test('same-day range: exactly at end', () {
        // 17:00 is NOT in 13:00–17:00 (end is exclusive)
        expect(
          SmartReminderAlgorithm.isInQuietHours(17 * 60, 13 * 60, 17 * 60),
          false,
        );
      });

      test('equal start and end disables quiet hours', () {
        // When start == end, no time is in quiet hours
        expect(
          SmartReminderAlgorithm.isInQuietHours(14 * 60, 22 * 60, 22 * 60),
          false,
        );
      });

      test('midnight-crossing: exactly at midnight', () {
        // 00:00 is in 22:00–08:00
        expect(
          SmartReminderAlgorithm.isInQuietHours(0, 22 * 60, 8 * 60),
          true,
        );
      });

      test('midnight-crossing: exactly at end boundary', () {
        // 08:00 is NOT in 22:00–08:00 (end is exclusive)
        expect(
          SmartReminderAlgorithm.isInQuietHours(8 * 60, 22 * 60, 8 * 60),
          false,
        );
      });
    });

    group('ReminderIntensity', () {
      test('has all expected values', () {
        expect(ReminderIntensity.values.length, 3);
        expect(ReminderIntensity.values, contains(ReminderIntensity.gentle));
        expect(ReminderIntensity.values, contains(ReminderIntensity.normal));
        expect(ReminderIntensity.values, contains(ReminderIntensity.urgent));
      });
    });
  });
}
