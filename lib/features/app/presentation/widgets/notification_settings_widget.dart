import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/notification_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for managing notification and reminder settings
class NotificationSettingsWidget extends ConsumerStatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  ConsumerState<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends ConsumerState<NotificationSettingsWidget> {
  late bool _notificationsEnabled;
  late bool _smartRemindersEnabled;
  late bool _streakWarningsEnabled;
  late TimeOfDay _reminderTime;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    final settings =
        settingsContainer.activeUserSettings.notificationSettings;
    _notificationsEnabled = settings.enabled;
    _smartRemindersEnabled = settings.smartRemindersEnabled;
    _streakWarningsEnabled = settings.streakWarningsEnabled;
    _reminderTime = settings.reminderTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

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
                    Icons.notifications_active,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.notificationSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                l10n.notificationSettingsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 24),

              // Enable/Disable Notifications
              _buildSettingContainer(
                theme,
                isSmallScreen,
                l10n.enableNotifications,
                l10n.enableNotificationsDescription,
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _onNotificationsToggled,
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Reminder Time
              if (_notificationsEnabled)
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.reminderTime,
                  l10n.reminderTimeDescription,
                  InkWell(
                    onTap: _selectReminderTime,
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
                            _reminderTime.format(context),
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

              if (_notificationsEnabled) SizedBox(height: isSmallScreen ? 16 : 20),

              // Smart Reminders
              if (_notificationsEnabled)
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.smartReminders,
                  l10n.smartRemindersDescription,
                  Switch(
                    value: _smartRemindersEnabled,
                    onChanged: (value) {
                      setState(() {
                        _smartRemindersEnabled = value;
                        settingsContainer.activeUserSettings
                            .notificationSettings.smartRemindersEnabled = value;
                      });
                    },
                  ),
                ),

              if (_notificationsEnabled) SizedBox(height: isSmallScreen ? 16 : 20),

              // Streak Warnings
              if (_notificationsEnabled)
                _buildSettingContainer(
                  theme,
                  isSmallScreen,
                  l10n.streakWarnings,
                  l10n.streakWarningsDescription,
                  Switch(
                    value: _streakWarningsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _streakWarningsEnabled = value;
                        settingsContainer.activeUserSettings
                            .notificationSettings.streakWarningsEnabled = value;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
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

  Future<void> _onNotificationsToggled(bool value) async {
    if (value) {
      // Request permissions first
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notificationPermissionDenied),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _notificationsEnabled = value;
      settingsContainer.activeUserSettings.notificationSettings.enabled = value;
    });

    // Schedule or cancel notifications
    if (value) {
      await _notificationService.scheduleDailyReminder(
        settingsContainer.activeUserSettings.notificationSettings,
      );
      LogWrapper.logger.i('Notifications enabled and scheduled');
    } else {
      await _notificationService.cancelAllNotifications();
      LogWrapper.logger.i('Notifications disabled and cancelled');
    }
  }

  Future<void> _selectReminderTime() async {
    final l10n = AppLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: l10n.selectReminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        settingsContainer.activeUserSettings.notificationSettings.reminderTime =
            picked;
      });

      // Reschedule notifications with new time
      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          settingsContainer.activeUserSettings.notificationSettings,
        );
      }
    }
  }
}
