import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/backup_scheduler.dart';
import 'package:day_tracker/core/settings/backup_settings.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/app/presentation/pages/backup_history_page.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupSettingsWidget extends ConsumerStatefulWidget {
  const BackupSettingsWidget({super.key});

  @override
  ConsumerState<BackupSettingsWidget> createState() =>
      _BackupSettingsWidgetState();
}

class _BackupSettingsWidgetState extends ConsumerState<BackupSettingsWidget> {
  late bool _backupEnabled;
  late BackupFrequency _frequency;
  late TimeOfDay _preferredTime;
  late bool _wifiOnly;
  late int _maxBackups;
  late BackupDestination _destination;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    final settings = settingsContainer.activeUserSettings.backupSettings;
    _backupEnabled = settings.enabled;
    _frequency = settings.frequency;
    _preferredTime = settings.preferredTime;
    _wifiOnly = settings.wifiOnly;
    _maxBackups = settings.maxBackups;
    _destination = settings.destination;
  }

  void _autoSave() => settingsContainer.saveSettings().ignore();

  bool get _isSupabaseConfigured {
    final s = settingsContainer.activeUserSettings.supabaseSettings;
    return s.supabaseUrl.isNotEmpty &&
        s.supabaseAnonKey.isNotEmpty &&
        s.email.isNotEmpty &&
        s.password.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final backupSettings = settingsContainer.activeUserSettings.backupSettings;
    final isOverdue = backupSettings.isBackupOverdue;
    final lastBackup = backupSettings.lastBackupDateTime;

    final customPath = backupSettings.backupDirectoryPath;
    final defaultPath = settingsContainer.applicationDocumentsPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overdue warning banner
        if (isOverdue)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SettingsStatusBanner.warning(
              context: context,
              text: lastBackup != null
                  ? l10n.lastBackup(_formatDateTime(lastBackup))
                  : l10n.lastBackupNever,
              trailingText: l10n.backupOverdue,
            ),
          ),

        SettingsSection(
          title: l10n.backupSettings,
          icon: Icons.backup_outlined,
          footer: _buildFooter(context, theme, l10n),
          children: [
            // Last backup status (when not overdue)
            if (!isOverdue && lastBackup != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: SettingsStatusBanner.success(
                  context: context,
                  text: l10n.lastBackup(_formatDateTime(lastBackup)),
                ),
              ),

            // Enable toggle
            SettingsTile(
              icon: Icons.backup,
              title: l10n.enableAutoBackup,
              subtitle: l10n.enableAutoBackupDescription,
              trailing: Switch(
                value: _backupEnabled,
                onChanged: _onBackupToggled,
              ),
            ),

            if (_backupEnabled) ...[
              // Frequency
              SettingsExpandedTile(
                icon: Icons.calendar_today_outlined,
                title: l10n.backupFrequency,
                subtitle: l10n.backupFrequencyDescription,
                control: SegmentedButton<BackupFrequency>(
                  segments: [
                    ButtonSegment(
                      value: BackupFrequency.daily,
                      label: Text(l10n.backupFrequencyDaily),
                    ),
                    ButtonSegment(
                      value: BackupFrequency.weekly,
                      label: Text(l10n.backupFrequencyWeekly),
                    ),
                    ButtonSegment(
                      value: BackupFrequency.monthly,
                      label: Text(l10n.backupFrequencyMonthly),
                    ),
                  ],
                  selected: {_frequency},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _frequency = selected.first;
                      settingsContainer.activeUserSettings.backupSettings
                          .frequency = _frequency;
                    });
                    _autoSave();
                  },
                ),
              ),

              // Preferred time
              SettingsTile(
                icon: Icons.schedule,
                title: l10n.backupPreferredTime,
                subtitle: l10n.backupPreferredTimeDescription,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.4),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    _preferredTime.format(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: _selectPreferredTime,
              ),

              // Destination
              SettingsExpandedTile(
                icon: Icons.storage_outlined,
                title: l10n.backupDestination,
                subtitle: _isSupabaseConfigured
                    ? l10n.backupDestinationDescription
                    : l10n.backupDestinationRequiresSupabase,
                control: SegmentedButton<BackupDestination>(
                  segments: [
                    ButtonSegment(
                      value: BackupDestination.localOnly,
                      label: Text(l10n.backupDestinationLocal),
                    ),
                    ButtonSegment(
                      value: BackupDestination.cloudOnly,
                      label: Text(l10n.backupDestinationCloud),
                      enabled: _isSupabaseConfigured,
                    ),
                    ButtonSegment(
                      value: BackupDestination.both,
                      label: Text(l10n.backupDestinationBoth),
                      enabled: _isSupabaseConfigured,
                    ),
                  ],
                  selected: {_destination},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _destination = selected.first;
                      settingsContainer.activeUserSettings.backupSettings
                          .destination = _destination;
                    });
                    BackupScheduler().updateSchedule(
                      settingsContainer.activeUserSettings.backupSettings,
                    );
                    _autoSave();
                  },
                ),
              ),

              // WiFi only (cloud)
              if (_destination != BackupDestination.localOnly)
                SettingsTile(
                  icon: Icons.wifi,
                  title: l10n.backupWifiOnly,
                  subtitle: l10n.backupWifiOnlyDescription,
                  trailing: Switch(
                    value: _wifiOnly,
                    onChanged: (value) {
                      setState(() {
                        _wifiOnly = value;
                        settingsContainer.activeUserSettings.backupSettings
                            .wifiOnly = value;
                      });
                      _autoSave();
                    },
                  ),
                ),

              // Max backups
              SettingsExpandedTile(
                icon: Icons.layers_outlined,
                title: l10n.backupMaxCount,
                subtitle: l10n.backupMaxCountDescription,
                control: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _maxBackups.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: l10n.backupMaxCountValue(_maxBackups),
                        onChanged: (value) {
                          setState(() {
                            _maxBackups = value.round();
                            settingsContainer
                                .activeUserSettings.backupSettings
                                .maxBackups = _maxBackups;
                          });
                        },
                        onChangeEnd: (_) => _autoSave(),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$_maxBackups',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),

              // Backup location (local)
              if (_destination != BackupDestination.cloudOnly) ...[
                SettingsTile(
                  icon: Icons.folder_open_outlined,
                  title: l10n.backupLocation,
                  subtitle: customPath != null
                      ? l10n.backupLocationCustom(customPath)
                      : l10n.backupLocationDefault(defaultPath),
                  trailing: TextButton(
                    onPressed: _selectBackupDirectory,
                    child: Text(l10n.backupLocationChange),
                  ),
                ),
                if (customPath != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 54, right: 16, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            settingsContainer
                                .activeUserSettings.backupSettings
                                .backupDirectoryPath = null;
                          });
                          _autoSave();
                        },
                        icon: const Icon(Icons.restore, size: 16),
                        label: Text(l10n.backupLocationReset),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              theme.colorScheme.onSurfaceVariant,
                          textStyle: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _isBackingUp ? null : _backupNow,
              icon: _isBackingUp
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.backup, size: 18),
              label: Text(
                _isBackingUp ? l10n.backupCreating : l10n.backupNow,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute(
                  builder: (context) => const BackupHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.history, size: 18),
            label: Text(l10n.backupHistory),
          ),
        ],
      ),
    );
  }

  void _onBackupToggled(bool value) {
    setState(() {
      _backupEnabled = value;
      settingsContainer.activeUserSettings.backupSettings.enabled = value;
    });
    _autoSave();

    BackupScheduler().updateSchedule(
      settingsContainer.activeUserSettings.backupSettings,
    );

    if (!value) {
      BackupScheduler().cancelScheduledBackups();
    }

    LogWrapper.logger.i('Auto-backup ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> _selectBackupDirectory() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && mounted) {
      setState(() {
        settingsContainer.activeUserSettings.backupSettings
            .backupDirectoryPath = selectedDirectory;
      });
      _autoSave();
    }
  }

  Future<void> _selectPreferredTime() async {
    final l10n = AppLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
      helpText: l10n.backupPreferredTime,
    );

    if (picked != null && picked != _preferredTime) {
      setState(() {
        _preferredTime = picked;
        settingsContainer.activeUserSettings.backupSettings.preferredTime =
            picked;
      });
      _autoSave();
    }
  }

  Future<void> _backupNow() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context);

    try {
      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      final notes = ref.read(notesLocalDataProvider);
      final habits = ref.read(habitsLocalDbDataProvider);
      final habitEntries = ref.read(habitEntriesLocalDbDataProvider);

      final metadata = await BackupScheduler().runBackup(
        diaryDays: diaryDays,
        notes: notes,
        habits: habits,
        habitEntries: habitEntries,
        type: BackupType.manual,
      );

      if (mounted) {
        setState(() => _isBackingUp = false);
        if (metadata.isSuccessful) {
          final message = metadata.cloudSynced
              ? '${l10n.backupSuccess} · ${l10n.backupUploadSuccess}'
              : l10n.backupSuccess;
          AppSnackBar.success(context, message: message);
        } else {
          AppSnackBar.error(
              context, message: l10n.backupFailed(metadata.error ?? ''));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBackingUp = false);
        AppSnackBar.error(context, message: l10n.backupFailed(e.toString()));
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
