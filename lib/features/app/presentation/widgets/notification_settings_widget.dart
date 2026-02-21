import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/notification_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _autoSave() => settingsContainer.saveSettings().ignore();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.notificationSettings,
      icon: Icons.notifications_outlined,
      children: [
        SettingsTile(
          icon: Icons.notifications_outlined,
          title: l10n.enableNotifications,
          subtitle: l10n.enableNotificationsDescription,
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: _onNotificationsToggled,
          ),
        ),
        if (_notificationsEnabled) ...[
          SettingsTile(
            icon: Icons.alarm,
            title: l10n.reminderTime,
            subtitle: l10n.reminderTimeDescription,
            trailing: _TimeChip(time: _reminderTime, context: context),
            onTap: _selectReminderTime,
          ),
          SettingsTile(
            icon: Icons.auto_awesome,
            title: l10n.smartReminders,
            subtitle: l10n.smartRemindersDescription,
            trailing: Switch(
              value: _smartRemindersEnabled,
              onChanged: (value) {
                setState(() {
                  _smartRemindersEnabled = value;
                  settingsContainer.activeUserSettings.notificationSettings
                      .smartRemindersEnabled = value;
                });
                _autoSave();
              },
            ),
          ),
          SettingsTile(
            icon: Icons.local_fire_department_outlined,
            title: l10n.streakWarnings,
            subtitle: l10n.streakWarningsDescription,
            trailing: Switch(
              value: _streakWarningsEnabled,
              onChanged: (value) {
                setState(() {
                  _streakWarningsEnabled = value;
                  settingsContainer.activeUserSettings.notificationSettings
                      .streakWarningsEnabled = value;
                });
                _autoSave();
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _onNotificationsToggled(bool value) async {
    if (value) {
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          AppSnackBar.error(
              context, message: l10n.notificationPermissionDenied);
        }
        return;
      }
    }

    setState(() {
      _notificationsEnabled = value;
      settingsContainer.activeUserSettings.notificationSettings.enabled = value;
    });
    _autoSave();

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
      _autoSave();

      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          settingsContainer.activeUserSettings.notificationSettings,
        );
      }
    }
  }
}

/// A styled chip showing a formatted time value.
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.context});

  final TimeOfDay time;
  final BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        time.format(context),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
