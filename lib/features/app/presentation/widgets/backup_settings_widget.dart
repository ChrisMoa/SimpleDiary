// ignore_for_file: public_member_api_docs
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
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for configuring automatic backup settings
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final backupSettings = settingsContainer.activeUserSettings.backupSettings;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.backup,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.backupSettings,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                l10n.backupSettingsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              // Last backup status
              _buildLastBackupStatus(theme, l10n, backupSettings),

              const SizedBox(height: 24),

              // Enable/Disable toggle
              _buildSettingContainer(
                theme,
                isSmallScreen,
                l10n.enableAutoBackup,
                l10n.enableAutoBackupDescription,
                Switch(
                  value: _backupEnabled,
                  onChanged: _onBackupToggled,
                ),
              ),

              if (_backupEnabled) ...[
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Frequency selector
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.backupFrequency,
                  l10n.backupFrequencyDescription,
                  SegmentedButton<BackupFrequency>(
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
                    },
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Preferred time
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.backupPreferredTime,
                  l10n.backupPreferredTimeDescription,
                  InkWell(
                    onTap: _selectPreferredTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _preferredTime.format(context),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Backup destination selector
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.backupDestination,
                  _isSupabaseConfigured
                      ? l10n.backupDestinationDescription
                      : l10n.backupDestinationRequiresSupabase,
                  SegmentedButton<BackupDestination>(
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
                    },
                  ),
                ),

                // WiFi only (only relevant when cloud is enabled)
                if (_destination != BackupDestination.localOnly) ...[
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  _buildSettingContainer(
                    theme,
                    isSmallScreen,
                    l10n.backupWifiOnly,
                    l10n.backupWifiOnlyDescription,
                    Switch(
                      value: _wifiOnly,
                      onChanged: (value) {
                        setState(() {
                          _wifiOnly = value;
                          settingsContainer.activeUserSettings.backupSettings
                              .wifiOnly = value;
                        });
                      },
                    ),
                  ),
                ],

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Max backups slider
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.backupMaxCount,
                  l10n.backupMaxCountDescription,
                  Column(
                    children: [
                      Slider(
                        value: _maxBackups.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: l10n.backupMaxCountValue(_maxBackups),
                        onChanged: (value) {
                          setState(() {
                            _maxBackups = value.round();
                            settingsContainer.activeUserSettings.backupSettings
                                .maxBackups = _maxBackups;
                          });
                        },
                      ),
                      Text(
                        l10n.backupMaxCountValue(_maxBackups),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Only show location picker when destination includes local storage
                if (_destination != BackupDestination.cloudOnly) ...[
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Backup location
                  _buildSettingContainer(
                    theme,
                    isSmallScreen,
                    l10n.backupLocation,
                    l10n.backupLocationDescription,
                    _buildBackupLocationControl(theme, l10n),
                  ),
                ],
              ],

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                          : const Icon(Icons.backup),
                      label: Text(
                        _isBackingUp ? l10n.backupCreating : l10n.backupNow,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BackupHistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: Text(l10n.backupHistory),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastBackupStatus(
    ThemeData theme,
    AppLocalizations l10n,
    BackupSettings settings,
  ) {
    final lastBackup = settings.lastBackupDateTime;
    final isOverdue = settings.isBackupOverdue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOverdue
            ? theme.colorScheme.errorContainer.withValues(alpha: .5)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: isOverdue
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            lastBackup != null
                ? l10n.lastBackup(_formatDateTime(lastBackup))
                : l10n.lastBackupNever,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
          if (isOverdue) ...[
            const Spacer(),
            Text(
              l10n.backupOverdue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingContainer(
    ThemeData theme,
    bool isSmallScreen,
    String title,
    String description,
    Widget control,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: .2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 16),
          control,
        ],
      ),
    );
  }

  void _onBackupToggled(bool value) {
    setState(() {
      _backupEnabled = value;
      settingsContainer.activeUserSettings.backupSettings.enabled = value;
    });

    // Update the schedule
    BackupScheduler().updateSchedule(
      settingsContainer.activeUserSettings.backupSettings,
    );

    if (!value) {
      BackupScheduler().cancelScheduledBackups();
    }

    LogWrapper.logger.i('Auto-backup ${value ? 'enabled' : 'disabled'}');
  }

  Widget _buildBackupLocationControl(ThemeData theme, AppLocalizations l10n) {
    final customPath = settingsContainer
        .activeUserSettings.backupSettings.backupDirectoryPath;
    final defaultPath = settingsContainer.applicationDocumentsPath;
    final isCustom = customPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCustom
                      ? l10n.backupLocationCustom(customPath)
                      : l10n.backupLocationDefault(defaultPath),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: _selectBackupDirectory,
              icon: const Icon(Icons.folder_open, size: 18),
              label: Text(l10n.backupLocationChange),
            ),
            if (isCustom)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    settingsContainer.activeUserSettings.backupSettings
                        .backupDirectoryPath = null;
                  });
                },
                icon: const Icon(Icons.restore, size: 18),
                label: Text(l10n.backupLocationReset),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectBackupDirectory() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && mounted) {
      setState(() {
        settingsContainer.activeUserSettings.backupSettings
            .backupDirectoryPath = selectedDirectory;
      });
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
        String message;
        if (metadata.isSuccessful) {
          message = metadata.cloudSynced
              ? '${l10n.backupSuccess} · ${l10n.backupUploadSuccess}'
              : l10n.backupSuccess;
        } else {
          message = l10n.backupFailed(metadata.error ?? '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: metadata.isSuccessful
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBackingUp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
