/// Intensity levels for smart reminder notifications.
///
/// Controls the tone and urgency of reminder messages:
/// - [gentle]: First reminder — friendly nudge
/// - [normal]: Second reminder — standard message
/// - [urgent]: Final reminder — last chance for the day
enum ReminderIntensity {
  gentle,
  normal,
  urgent,
}

/// Pure logic for deciding when and how to send smart reminders.
///
/// All methods are static and have no Flutter/platform dependencies,
/// making them fully unit-testable.
class SmartReminderAlgorithm {
  /// Determine whether a smart reminder should be sent right now.
  ///
  /// Returns `false` when:
  /// - The user has already written today's entry
  /// - The maximum number of reminders for today has been reached
  /// - The current time falls within quiet hours
  static bool shouldSendReminder({
    required DateTime now,
    required bool hasEntryToday,
    required int remindersSentToday,
    required int maxRemindersPerDay,
    required int quietHoursStartMinutes,
    required int quietHoursEndMinutes,
  }) {
    if (hasEntryToday) return false;
    if (remindersSentToday >= maxRemindersPerDay) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    if (isInQuietHours(
      currentMinutes,
      quietHoursStartMinutes,
      quietHoursEndMinutes,
    )) {
      return false;
    }

    return true;
  }

  /// Calculate the reminder intensity based on how many have been sent today.
  ///
  /// - 0 sent → [ReminderIntensity.gentle]
  /// - 1 sent → [ReminderIntensity.normal]
  /// - 2+ sent → [ReminderIntensity.urgent]
  static ReminderIntensity calculateIntensity(int remindersSentToday) {
    if (remindersSentToday <= 0) return ReminderIntensity.gentle;
    if (remindersSentToday == 1) return ReminderIntensity.normal;
    return ReminderIntensity.urgent;
  }

  /// Check whether [currentMinutes] falls within the quiet-hours window.
  ///
  /// Handles midnight-crossing ranges correctly (e.g. 22:00–08:00).
  /// When [startMinutes] equals [endMinutes], quiet hours are effectively
  /// disabled (no time is "in" quiet hours).
  static bool isInQuietHours(
    int currentMinutes,
    int startMinutes,
    int endMinutes,
  ) {
    if (startMinutes == endMinutes) return false;

    if (startMinutes < endMinutes) {
      // Same-day range, e.g. 13:00–17:00
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Midnight-crossing range, e.g. 22:00–08:00
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }
}
