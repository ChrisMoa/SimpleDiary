// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'package:flutter/material.dart';

/// Frequency options for automatic backups
enum BackupFrequency {
  daily,
  weekly,
  monthly;

  String toJson() => name;

  static BackupFrequency fromJson(String json) {
    return BackupFrequency.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BackupFrequency.weekly,
    );
  }
}

/// Where backups should be stored
enum BackupDestination {
  localOnly,
  cloudOnly,
  both;

  String toJson() => name;

  static BackupDestination fromJson(String json) {
    return BackupDestination.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BackupDestination.localOnly,
    );
  }
}

/// Settings for automatic scheduled backups
class BackupSettings {
  /// Master toggle for automatic backups
  bool enabled;

  /// How often to run automatic backups
  BackupFrequency frequency;

  /// Preferred time of day for backups (stored as minutes since midnight)
  int preferredTimeMinutes;

  /// Only run backups on WiFi (Android only)
  bool wifiOnly;

  /// Maximum number of backups to keep
  int maxBackups;

  /// ISO 8601 string of the last successful backup time (null if never backed up)
  String? lastBackupTimestamp;

  /// Directory path for storing local backups (null = default app documents path)
  String? backupDirectoryPath;

  /// Where backups should be stored (local, cloud, or both)
  BackupDestination destination;

  /// Whether cloud storage is enabled (destination includes cloud)
  bool get isCloudEnabled => destination != BackupDestination.localOnly;

  BackupSettings({
    required this.enabled,
    required this.frequency,
    required this.preferredTimeMinutes,
    required this.wifiOnly,
    required this.maxBackups,
    this.lastBackupTimestamp,
    this.backupDirectoryPath,
    this.destination = BackupDestination.localOnly,
  });

  /// Convert minutes since midnight to TimeOfDay
  TimeOfDay get preferredTime {
    final hours = preferredTimeMinutes ~/ 60;
    final minutes = preferredTimeMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  /// Set preferred time from TimeOfDay
  set preferredTime(TimeOfDay time) {
    preferredTimeMinutes = time.hour * 60 + time.minute;
  }

  /// Get the last backup as DateTime, or null if never backed up
  DateTime? get lastBackupDateTime {
    if (lastBackupTimestamp == null) return null;
    return DateTime.tryParse(lastBackupTimestamp!);
  }

  /// Check if a backup is overdue based on the configured frequency
  bool get isBackupOverdue {
    if (!enabled) return false;
    final lastBackup = lastBackupDateTime;
    if (lastBackup == null) return true;

    final now = DateTime.now();
    switch (frequency) {
      case BackupFrequency.daily:
        return now.difference(lastBackup).inHours >= 24;
      case BackupFrequency.weekly:
        return now.difference(lastBackup).inDays >= 7;
      case BackupFrequency.monthly:
        return now.difference(lastBackup).inDays >= 30;
    }
  }

  /// Create default backup settings (disabled)
  factory BackupSettings.fromEmpty() => BackupSettings(
        enabled: false,
        frequency: BackupFrequency.weekly,
        preferredTimeMinutes: 2 * 60, // 02:00 (2 AM)
        wifiOnly: true,
        maxBackups: 10,
      );

  /// Serialize to JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'frequency': frequency.toJson(),
      'preferredTimeMinutes': preferredTimeMinutes,
      'wifiOnly': wifiOnly,
      'maxBackups': maxBackups,
      'lastBackupTimestamp': lastBackupTimestamp,
      'backupDirectoryPath': backupDirectoryPath,
      'destination': destination.toJson(),
    };
  }

  /// Deserialize from JSON
  factory BackupSettings.fromMap(Map<String, dynamic> map) {
    return BackupSettings(
      enabled: map['enabled'] as bool? ?? false,
      frequency: BackupFrequency.fromJson(map['frequency'] as String? ?? 'weekly'),
      preferredTimeMinutes: map['preferredTimeMinutes'] as int? ?? 2 * 60,
      wifiOnly: map['wifiOnly'] as bool? ?? true,
      maxBackups: map['maxBackups'] as int? ?? 10,
      lastBackupTimestamp: map['lastBackupTimestamp'] as String?,
      backupDirectoryPath: map['backupDirectoryPath'] as String?,
      destination: map['destination'] != null
          ? BackupDestination.fromJson(map['destination'] as String)
          : (map['cloudSyncEnabled'] as bool? ?? false)
              ? BackupDestination.both
              : BackupDestination.localOnly,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupSettings.fromJson(String source) =>
      BackupSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with optional field updates
  BackupSettings copyWith({
    bool? enabled,
    BackupFrequency? frequency,
    int? preferredTimeMinutes,
    bool? wifiOnly,
    int? maxBackups,
    String? lastBackupTimestamp,
    String? backupDirectoryPath,
    BackupDestination? destination,
  }) {
    return BackupSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      preferredTimeMinutes: preferredTimeMinutes ?? this.preferredTimeMinutes,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      maxBackups: maxBackups ?? this.maxBackups,
      lastBackupTimestamp: lastBackupTimestamp ?? this.lastBackupTimestamp,
      backupDirectoryPath: backupDirectoryPath ?? this.backupDirectoryPath,
      destination: destination ?? this.destination,
    );
  }

  @override
  String toString() {
    final time = preferredTime;
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return 'BackupSettings(enabled: $enabled, frequency: ${frequency.name}, time: $timeStr, wifiOnly: $wifiOnly, maxBackups: $maxBackups, destination: ${destination.name}, lastBackup: $lastBackupTimestamp)';
  }
}
