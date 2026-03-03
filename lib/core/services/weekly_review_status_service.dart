import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-based tracking for weekly review due/shown status.
///
/// Follows the same pattern as [DiaryStatusService].
class WeeklyReviewStatusService {
  static const _lastReviewYearKey = 'weekly_review_last_year';
  static const _lastReviewWeekKey = 'weekly_review_last_week';

  /// Check whether a review is due for the previous week.
  ///
  /// Returns `true` if the last completed week has not been reviewed yet.
  static Future<bool> isReviewDueForLastWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final lastYear = prefs.getInt(_lastReviewYearKey);
    final lastWeek = prefs.getInt(_lastReviewWeekKey);

    final (prevYear, prevWeek) = _previousWeek();

    // No review ever shown → due
    if (lastYear == null || lastWeek == null) return true;

    // Already reviewed this week → not due
    if (lastYear == prevYear && lastWeek == prevWeek) return false;

    // Reviewed a different (older) week → due
    return true;
  }

  /// Mark that the review for the given week has been shown.
  static Future<void> markReviewShown(int year, int weekNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReviewYearKey, year);
    await prefs.setInt(_lastReviewWeekKey, weekNumber);
  }

  /// Get the last reviewed year and week, or `null` if none.
  static Future<({int year, int week})?> getLastReviewedWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final year = prefs.getInt(_lastReviewYearKey);
    final week = prefs.getInt(_lastReviewWeekKey);
    if (year == null || week == null) return null;
    return (year: year, week: week);
  }

  /// Clear all stored state.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReviewYearKey);
    await prefs.remove(_lastReviewWeekKey);
  }

  /// Calculate the previous week's (year, weekNumber).
  static (int year, int week) _previousWeek() {
    final now = DateTime.now();
    // Go back to last Sunday (end of previous week)
    final lastSunday = now.subtract(Duration(days: now.weekday));
    // Monday of the previous week
    final lastMonday = lastSunday.subtract(const Duration(days: 6));
    final weekNumber = WeeklyReviewData.isoWeekNumber(lastMonday);
    return (lastMonday.year, weekNumber);
  }
}
