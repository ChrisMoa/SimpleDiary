// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'package:flutter/material.dart';

/// Settings for notification and reminder configuration
class NotificationSettings {
  /// Master toggle for all notifications
  bool enabled;

  /// Time of day for daily reminders (stored as minutes since midnight)
  int reminderTimeMinutes;

  /// Only remind if today's diary entry is missing
  bool smartRemindersEnabled;

  /// Warn when streak is at risk
  bool streakWarningsEnabled;

  /// Days of week to show reminders (1=Monday, 7=Sunday)
  /// Empty list means all days
  List<int> reminderDays;

  /// Maximum number of smart reminders to send per day (1–5)
  int maxSmartRemindersPerDay;

  /// Start of quiet hours (minutes since midnight, e.g. 1320 = 22:00)
  int quietHoursStartMinutes;

  /// End of quiet hours (minutes since midnight, e.g. 480 = 08:00)
  int quietHoursEndMinutes;

  /// Whether weekly review notifications are enabled
  bool weeklyReviewEnabled;

  /// Day of week for the weekly review notification (1=Monday, 7=Sunday)
  int weeklyReviewDay;

  /// Time for weekly review notification (minutes since midnight)
  int weeklyReviewTimeMinutes;

  NotificationSettings({
    required this.enabled,
    required this.reminderTimeMinutes,
    required this.smartRemindersEnabled,
    required this.streakWarningsEnabled,
    required this.reminderDays,
    required this.maxSmartRemindersPerDay,
    required this.quietHoursStartMinutes,
    required this.quietHoursEndMinutes,
    required this.weeklyReviewEnabled,
    required this.weeklyReviewDay,
    required this.weeklyReviewTimeMinutes,
  });

  /// Convert minutes since midnight to TimeOfDay
  TimeOfDay get reminderTime {
    final hours = reminderTimeMinutes ~/ 60;
    final minutes = reminderTimeMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  /// Set reminder time from TimeOfDay
  set reminderTime(TimeOfDay time) {
    reminderTimeMinutes = time.hour * 60 + time.minute;
  }

  /// Convert quiet hours start to TimeOfDay
  TimeOfDay get quietHoursStart {
    final hours = quietHoursStartMinutes ~/ 60;
    final minutes = quietHoursStartMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  /// Set quiet hours start from TimeOfDay
  set quietHoursStart(TimeOfDay time) {
    quietHoursStartMinutes = time.hour * 60 + time.minute;
  }

  /// Convert quiet hours end to TimeOfDay
  TimeOfDay get quietHoursEnd {
    final hours = quietHoursEndMinutes ~/ 60;
    final minutes = quietHoursEndMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  /// Set quiet hours end from TimeOfDay
  set quietHoursEnd(TimeOfDay time) {
    quietHoursEndMinutes = time.hour * 60 + time.minute;
  }

  /// Convert weekly review time to TimeOfDay
  TimeOfDay get weeklyReviewTime {
    final hours = weeklyReviewTimeMinutes ~/ 60;
    final minutes = weeklyReviewTimeMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  /// Set weekly review time from TimeOfDay
  set weeklyReviewTime(TimeOfDay time) {
    weeklyReviewTimeMinutes = time.hour * 60 + time.minute;
  }

  /// Create default notification settings
  factory NotificationSettings.fromEmpty() => NotificationSettings(
        enabled: false,
        reminderTimeMinutes: 20 * 60, // 20:00 (8 PM)
        smartRemindersEnabled: true,
        streakWarningsEnabled: true,
        reminderDays: [], // All days
        maxSmartRemindersPerDay: 3,
        quietHoursStartMinutes: 22 * 60, // 22:00
        quietHoursEndMinutes: 8 * 60, // 08:00
        weeklyReviewEnabled: true,
        weeklyReviewDay: 7, // Sunday
        weeklyReviewTimeMinutes: 20 * 60, // 20:00
      );

  /// Serialize to JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'reminderTimeMinutes': reminderTimeMinutes,
      'smartRemindersEnabled': smartRemindersEnabled,
      'streakWarningsEnabled': streakWarningsEnabled,
      'reminderDays': reminderDays,
      'maxSmartRemindersPerDay': maxSmartRemindersPerDay,
      'quietHoursStartMinutes': quietHoursStartMinutes,
      'quietHoursEndMinutes': quietHoursEndMinutes,
      'weeklyReviewEnabled': weeklyReviewEnabled,
      'weeklyReviewDay': weeklyReviewDay,
      'weeklyReviewTimeMinutes': weeklyReviewTimeMinutes,
    };
  }

  /// Deserialize from JSON
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] as bool? ?? false,
      reminderTimeMinutes: map['reminderTimeMinutes'] as int? ?? 20 * 60,
      smartRemindersEnabled: map['smartRemindersEnabled'] as bool? ?? true,
      streakWarningsEnabled: map['streakWarningsEnabled'] as bool? ?? true,
      reminderDays: List<int>.from((map['reminderDays'] as List?) ?? []),
      maxSmartRemindersPerDay: map['maxSmartRemindersPerDay'] as int? ?? 3,
      quietHoursStartMinutes: map['quietHoursStartMinutes'] as int? ?? 22 * 60,
      quietHoursEndMinutes: map['quietHoursEndMinutes'] as int? ?? 8 * 60,
      weeklyReviewEnabled: map['weeklyReviewEnabled'] as bool? ?? true,
      weeklyReviewDay: map['weeklyReviewDay'] as int? ?? 7,
      weeklyReviewTimeMinutes: map['weeklyReviewTimeMinutes'] as int? ?? 20 * 60,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationSettings.fromJson(String source) =>
      NotificationSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with optional field updates
  NotificationSettings copyWith({
    bool? enabled,
    int? reminderTimeMinutes,
    bool? smartRemindersEnabled,
    bool? streakWarningsEnabled,
    List<int>? reminderDays,
    int? maxSmartRemindersPerDay,
    int? quietHoursStartMinutes,
    int? quietHoursEndMinutes,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
    int? weeklyReviewTimeMinutes,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
      streakWarningsEnabled: streakWarningsEnabled ?? this.streakWarningsEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      maxSmartRemindersPerDay: maxSmartRemindersPerDay ?? this.maxSmartRemindersPerDay,
      quietHoursStartMinutes: quietHoursStartMinutes ?? this.quietHoursStartMinutes,
      quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
      weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
      weeklyReviewDay: weeklyReviewDay ?? this.weeklyReviewDay,
      weeklyReviewTimeMinutes: weeklyReviewTimeMinutes ?? this.weeklyReviewTimeMinutes,
    );
  }

  @override
  String toString() {
    final time = reminderTime;
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final qStart = quietHoursStart;
    final qEnd = quietHoursEnd;
    final qStartStr = '${qStart.hour.toString().padLeft(2, '0')}:${qStart.minute.toString().padLeft(2, '0')}';
    final qEndStr = '${qEnd.hour.toString().padLeft(2, '0')}:${qEnd.minute.toString().padLeft(2, '0')}';
    final wrTime = weeklyReviewTime;
    final wrTimeStr = '${wrTime.hour.toString().padLeft(2, '0')}:${wrTime.minute.toString().padLeft(2, '0')}';
    return 'NotificationSettings(enabled: $enabled, reminderTime: $timeStr, smartReminders: $smartRemindersEnabled, streakWarnings: $streakWarningsEnabled, days: $reminderDays, maxSmartReminders: $maxSmartRemindersPerDay, quietHours: $qStartStr-$qEndStr, weeklyReview: $weeklyReviewEnabled day=$weeklyReviewDay time=$wrTimeStr)';
  }
}
