// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/backup_service.dart';
import 'package:day_tracker/core/services/cloud_backup_service.dart';
import 'package:day_tracker/core/settings/backup_settings.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:workmanager/workmanager.dart';

/// Task name used for Workmanager registration
const String scheduledBackupTaskName = 'scheduled_backup';

/// Manages scheduling and execution of automatic backups.
///
/// On Android, uses Workmanager for true background execution.
/// On desktop (Linux/Windows), checks on app startup if a backup is overdue.
class BackupScheduler {
  static final BackupScheduler _instance = BackupScheduler._internal();
  factory BackupScheduler() => _instance;
  BackupScheduler._internal();

  /// Register or cancel the periodic backup task based on settings.
  /// Call this on app startup and when backup settings change.
  Future<void> updateSchedule(BackupSettings settings) async {
    if (activePlatform.platform == ActivePlatform.android) {
      await _updateAndroidSchedule(settings);
    }
    // Desktop: no persistent scheduler — handled by checkAndRunOverdueBackup()
  }

  /// Cancel all scheduled backup tasks
  Future<void> cancelScheduledBackups() async {
    if (activePlatform.platform == ActivePlatform.android) {
      try {
        await Workmanager().cancelByUniqueName(scheduledBackupTaskName);
        LogWrapper.logger.i('Scheduled backup cancelled');
      } catch (e) {
        LogWrapper.logger.e('Error cancelling scheduled backup: $e');
      }
    }
  }

  /// Check if a backup is overdue and run one if needed.
  /// Call this on app startup for all platforms.
  Future<BackupMetadata?> checkAndRunOverdueBackup({
    required List<DiaryDay> diaryDays,
    required List<Note> notes,
    required List<Habit> habits,
    required List<HabitEntry> habitEntries,
  }) async {
    final settings = settingsContainer.activeUserSettings.backupSettings;
    if (!settings.enabled) return null;
    if (!settings.isBackupOverdue) {
      LogWrapper.logger.d('Backup not overdue, skipping');
      return null;
    }

    LogWrapper.logger.i('Backup is overdue, running scheduled backup...');
    return await runBackup(
      diaryDays: diaryDays,
      notes: notes,
      habits: habits,
      habitEntries: habitEntries,
      type: BackupType.scheduled,
    );
  }

  /// Execute a backup with the given data.
  /// Creates a local backup, then optionally uploads to cloud if enabled.
  Future<BackupMetadata> runBackup({
    required List<DiaryDay> diaryDays,
    required List<Note> notes,
    required List<Habit> habits,
    required List<HabitEntry> habitEntries,
    required BackupType type,
  }) async {
    // Step 1: Create local backup
    var metadata = await BackupService().createBackup(
      diaryDaysJson: diaryDays.map((d) => d.toMap()).toList(),
      notesJson: notes.map((n) => n.toLocalDbMap(n)).toList(),
      habitsJson: habits.map((h) => h.toLocalDbMap(h)).toList(),
      habitEntriesJson: habitEntries.map((e) => e.toLocalDbMap(e)).toList(),
      type: type,
    );

    // Step 2: Optionally upload to cloud (never fails the local backup)
    if (metadata.isSuccessful) {
      metadata = await _tryCloudUpload(metadata);
    }

    return metadata;
  }

  /// Attempt to upload a backup to cloud storage if cloud sync is enabled.
  /// Returns updated metadata with cloudSynced flag on success.
  Future<BackupMetadata> _tryCloudUpload(BackupMetadata metadata) async {
    final settings = settingsContainer.activeUserSettings.backupSettings;
    if (!settings.cloudSyncEnabled) return metadata;

    final success = await CloudBackupService().uploadBackup(metadata);
    if (success) {
      final updated = metadata.copyWith(cloudSynced: true);
      await BackupService().updateMetadataInIndex(updated);
      LogWrapper.logger.i('Backup ${metadata.id} synced to cloud');
      return updated;
    } else {
      LogWrapper.logger.w('Backup ${metadata.id} cloud sync failed (non-fatal)');
      return metadata;
    }
  }

  // -- Android Workmanager scheduling --

  Future<void> _updateAndroidSchedule(BackupSettings settings) async {
    try {
      // Always cancel existing first
      await Workmanager().cancelByUniqueName(scheduledBackupTaskName);

      if (!settings.enabled) {
        LogWrapper.logger.i('Auto-backup disabled, schedule cleared');
        return;
      }

      final frequency = _frequencyToDuration(settings.frequency);

      // When cloud sync is enabled, require network connectivity
      final NetworkType networkType;
      if (settings.cloudSyncEnabled) {
        networkType = settings.wifiOnly
            ? NetworkType.unmetered
            : NetworkType.connected;
      } else {
        networkType = NetworkType.not_required;
      }

      await Workmanager().registerPeriodicTask(
        scheduledBackupTaskName,
        scheduledBackupTaskName,
        frequency: frequency,
        constraints: Constraints(
          networkType: networkType,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      LogWrapper.logger.i(
        'Scheduled backup registered: ${settings.frequency.name} '
        '(every ${frequency.inHours}h, cloudSync: ${settings.cloudSyncEnabled}, '
        'wifiOnly: ${settings.wifiOnly})',
      );
    } catch (e) {
      LogWrapper.logger.e('Error scheduling backup: $e');
    }
  }

  Duration _frequencyToDuration(BackupFrequency frequency) {
    switch (frequency) {
      case BackupFrequency.daily:
        return const Duration(hours: 24);
      case BackupFrequency.weekly:
        return const Duration(hours: 24 * 7);
      case BackupFrequency.monthly:
        return const Duration(hours: 24 * 30);
    }
  }
}
