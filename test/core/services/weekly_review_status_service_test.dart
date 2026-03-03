import 'package:day_tracker/core/services/weekly_review_status_service.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WeeklyReviewStatusService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ── isReviewDueForLastWeek ──────────────────────────────────────────────

    test('isReviewDueForLastWeek returns true when no review ever shown', () async {
      final result = await WeeklyReviewStatusService.isReviewDueForLastWeek();
      expect(result, true);
    });

    test('isReviewDueForLastWeek returns false after marking current previous week', () async {
      // Calculate the previous week (same logic as the service)
      final now = DateTime.now();
      final lastSunday = now.subtract(Duration(days: now.weekday));
      final lastMonday = lastSunday.subtract(const Duration(days: 6));
      final weekNumber = WeeklyReviewData.isoWeekNumber(lastMonday);

      await WeeklyReviewStatusService.markReviewShown(lastMonday.year, weekNumber);

      final result = await WeeklyReviewStatusService.isReviewDueForLastWeek();
      expect(result, false);
    });

    test('isReviewDueForLastWeek returns true for an older reviewed week', () async {
      // Mark a week from long ago
      await WeeklyReviewStatusService.markReviewShown(2024, 1);

      final result = await WeeklyReviewStatusService.isReviewDueForLastWeek();
      expect(result, true);
    });

    test('isReviewDueForLastWeek returns true when only year is stored', () async {
      SharedPreferences.setMockInitialValues({
        'weekly_review_last_year': 2026,
      });

      final result = await WeeklyReviewStatusService.isReviewDueForLastWeek();
      expect(result, true);
    });

    test('isReviewDueForLastWeek returns true when only week is stored', () async {
      SharedPreferences.setMockInitialValues({
        'weekly_review_last_week': 5,
      });

      final result = await WeeklyReviewStatusService.isReviewDueForLastWeek();
      expect(result, true);
    });

    // ── markReviewShown ─────────────────────────────────────────────────────

    test('markReviewShown stores year and week', () async {
      await WeeklyReviewStatusService.markReviewShown(2026, 9);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('weekly_review_last_year'), 2026);
      expect(prefs.getInt('weekly_review_last_week'), 9);
    });

    test('markReviewShown overwrites previous values', () async {
      await WeeklyReviewStatusService.markReviewShown(2025, 52);
      await WeeklyReviewStatusService.markReviewShown(2026, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('weekly_review_last_year'), 2026);
      expect(prefs.getInt('weekly_review_last_week'), 1);
    });

    // ── getLastReviewedWeek ─────────────────────────────────────────────────

    test('getLastReviewedWeek returns null when no review shown', () async {
      final result = await WeeklyReviewStatusService.getLastReviewedWeek();
      expect(result, isNull);
    });

    test('getLastReviewedWeek returns year and week after mark', () async {
      await WeeklyReviewStatusService.markReviewShown(2026, 8);

      final result = await WeeklyReviewStatusService.getLastReviewedWeek();
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.week, 8);
    });

    test('getLastReviewedWeek returns null when only year is stored', () async {
      SharedPreferences.setMockInitialValues({
        'weekly_review_last_year': 2026,
      });

      final result = await WeeklyReviewStatusService.getLastReviewedWeek();
      expect(result, isNull);
    });

    // ── clear ───────────────────────────────────────────────────────────────

    test('clear removes all stored state', () async {
      await WeeklyReviewStatusService.markReviewShown(2026, 5);

      await WeeklyReviewStatusService.clear();

      final result = await WeeklyReviewStatusService.getLastReviewedWeek();
      expect(result, isNull);
    });

    test('clear makes isReviewDueForLastWeek return true again', () async {
      // Calculate the previous week
      final now = DateTime.now();
      final lastSunday = now.subtract(Duration(days: now.weekday));
      final lastMonday = lastSunday.subtract(const Duration(days: 6));
      final weekNumber = WeeklyReviewData.isoWeekNumber(lastMonday);

      await WeeklyReviewStatusService.markReviewShown(lastMonday.year, weekNumber);
      expect(await WeeklyReviewStatusService.isReviewDueForLastWeek(), false);

      await WeeklyReviewStatusService.clear();
      expect(await WeeklyReviewStatusService.isReviewDueForLastWeek(), true);
    });

    // ── lifecycle ───────────────────────────────────────────────────────────

    test('full lifecycle: due → mark → not due → clear → due', () async {
      // Initially due
      expect(await WeeklyReviewStatusService.isReviewDueForLastWeek(), true);
      expect(await WeeklyReviewStatusService.getLastReviewedWeek(), isNull);

      // Mark previous week as shown
      final now = DateTime.now();
      final lastSunday = now.subtract(Duration(days: now.weekday));
      final lastMonday = lastSunday.subtract(const Duration(days: 6));
      final weekNumber = WeeklyReviewData.isoWeekNumber(lastMonday);
      await WeeklyReviewStatusService.markReviewShown(lastMonday.year, weekNumber);

      // No longer due
      expect(await WeeklyReviewStatusService.isReviewDueForLastWeek(), false);
      final reviewed = await WeeklyReviewStatusService.getLastReviewedWeek();
      expect(reviewed!.year, lastMonday.year);
      expect(reviewed.week, weekNumber);

      // Clear resets everything
      await WeeklyReviewStatusService.clear();
      expect(await WeeklyReviewStatusService.isReviewDueForLastWeek(), true);
      expect(await WeeklyReviewStatusService.getLastReviewedWeek(), isNull);
    });
  });
}
