import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight SharedPreferences-based service for tracking diary entry status.
///
/// Designed to work in both the main app isolate and the Workmanager
/// background isolate (which has no access to Riverpod providers or SQLite).
///
/// The app calls [markEntryWritten] whenever a diary day is saved.
/// The background task calls [hasEntryForToday] to decide whether to
/// send a smart reminder notification.
class DiaryStatusService {
  static const _keyLastEntryDate = 'diary_last_entry_date';
  static const _keySmartRemindersSentToday = 'smart_reminders_sent_today';
  static const _keySmartRemindersDate = 'smart_reminders_date';

  /// Mark that a diary entry was written for today.
  ///
  /// Called from the app when the user saves a diary day (rating or PERMA+).
  static Future<void> markEntryWritten() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayIso();
    await prefs.setString(_keyLastEntryDate, today);
  }

  /// Check whether a diary entry exists for today.
  ///
  /// Compares the stored last-entry date with today's ISO date string.
  static Future<bool> hasEntryForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyLastEntryDate);
    if (lastDate == null) return false;
    return lastDate == _todayIso();
  }

  /// Get the number of smart reminders sent today.
  ///
  /// Automatically resets to 0 when the date changes (new day).
  static Future<int> getRemindersSentToday() async {
    final prefs = await SharedPreferences.getInstance();
    final date = prefs.getString(_keySmartRemindersDate);
    final today = _todayIso();

    if (date != today) {
      // New day — reset counter
      await prefs.setString(_keySmartRemindersDate, today);
      await prefs.setInt(_keySmartRemindersSentToday, 0);
      return 0;
    }

    return prefs.getInt(_keySmartRemindersSentToday) ?? 0;
  }

  /// Increment the smart reminder counter for today.
  ///
  /// Called after successfully showing a smart reminder notification.
  static Future<void> incrementReminderCount() async {
    final current = await getRemindersSentToday();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySmartRemindersSentToday, current + 1);
  }

  /// Today's date as an ISO date string (YYYY-MM-DD).
  static String _todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
