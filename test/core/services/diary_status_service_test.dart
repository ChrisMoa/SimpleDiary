import 'package:day_tracker/core/services/diary_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DiaryStatusService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ── markEntryWritten / hasEntryForToday ──────────────────────────────────

    test('hasEntryForToday returns false when no entry has been written', () async {
      final result = await DiaryStatusService.hasEntryForToday();
      expect(result, false);
    });

    test('hasEntryForToday returns true after markEntryWritten', () async {
      await DiaryStatusService.markEntryWritten();
      final result = await DiaryStatusService.hasEntryForToday();
      expect(result, true);
    });

    test('hasEntryForToday returns false for a different day', () async {
      // Pre-seed with yesterday's date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'diary_last_entry_date': dateStr,
      });

      final result = await DiaryStatusService.hasEntryForToday();
      expect(result, false);
    });

    test('markEntryWritten stores today ISO date', () async {
      await DiaryStatusService.markEntryWritten();

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('diary_last_entry_date');

      final now = DateTime.now();
      final expectedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(stored, expectedDate);
    });

    // ── getRemindersSentToday / incrementReminderCount ───────────────────────

    test('getRemindersSentToday returns 0 when no reminders sent', () async {
      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 0);
    });

    test('incrementReminderCount increases count', () async {
      await DiaryStatusService.incrementReminderCount();
      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 1);
    });

    test('incrementReminderCount increments multiple times', () async {
      await DiaryStatusService.incrementReminderCount();
      await DiaryStatusService.incrementReminderCount();
      await DiaryStatusService.incrementReminderCount();

      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 3);
    });

    test('getRemindersSentToday resets on new day', () async {
      // Pre-seed with yesterday's date and a non-zero count
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'smart_reminders_date': dateStr,
        'smart_reminders_sent_today': 5,
      });

      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 0);
    });

    test('getRemindersSentToday preserves count on same day', () async {
      // Write today's date and a count
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'smart_reminders_date': todayStr,
        'smart_reminders_sent_today': 2,
      });

      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 2);
    });

    test('increment after day reset starts from 1', () async {
      // Pre-seed with yesterday's date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'smart_reminders_date': dateStr,
        'smart_reminders_sent_today': 5,
      });

      // This should first reset to 0, then getRemindersSentToday returns 0
      await DiaryStatusService.incrementReminderCount();
      final count = await DiaryStatusService.getRemindersSentToday();
      expect(count, 1);
    });
  });
}
