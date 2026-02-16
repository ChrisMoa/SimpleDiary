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

  NotificationSettings({
    required this.enabled,
    required this.reminderTimeMinutes,
    required this.smartRemindersEnabled,
    required this.streakWarningsEnabled,
    required this.reminderDays,
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

  /// Create default notification settings
  factory NotificationSettings.fromEmpty() => NotificationSettings(
        enabled: false,
        reminderTimeMinutes: 20 * 60, // 20:00 (8 PM)
        smartRemindersEnabled: true,
        streakWarningsEnabled: true,
        reminderDays: [], // All days
      );

  /// Serialize to JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'reminderTimeMinutes': reminderTimeMinutes,
      'smartRemindersEnabled': smartRemindersEnabled,
      'streakWarningsEnabled': streakWarningsEnabled,
      'reminderDays': reminderDays,
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
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
      streakWarningsEnabled: streakWarningsEnabled ?? this.streakWarningsEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  @override
  String toString() {
    final time = reminderTime;
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return 'NotificationSettings(enabled: $enabled, reminderTime: $timeStr, smartReminders: $smartRemindersEnabled, streakWarnings: $streakWarningsEnabled, days: $reminderDays)';
  }
}
