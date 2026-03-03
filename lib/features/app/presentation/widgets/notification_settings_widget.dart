import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/notification_service.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
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
  late int _maxSmartRemindersPerDay;
  late TimeOfDay _quietHoursStart;
  late TimeOfDay _quietHoursEnd;
  late bool _weeklyReviewEnabled;
  late int _weeklyReviewDay;
  late TimeOfDay _weeklyReviewTime;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    final settings =
        ref.read(settingsProvider).activeUserSettings.notificationSettings;
    _notificationsEnabled = settings.enabled;
    _smartRemindersEnabled = settings.smartRemindersEnabled;
    _streakWarningsEnabled = settings.streakWarningsEnabled;
    _reminderTime = settings.reminderTime;
    _maxSmartRemindersPerDay = settings.maxSmartRemindersPerDay;
    _quietHoursStart = settings.quietHoursStart;
    _quietHoursEnd = settings.quietHoursEnd;
    _weeklyReviewEnabled = settings.weeklyReviewEnabled;
    _weeklyReviewDay = settings.weeklyReviewDay;
    _weeklyReviewTime = settings.weeklyReviewTime;
  }

  void _autoSave() => ref.read(settingsNotifierProvider).saveSettings().ignore();

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
              onChanged: _onSmartRemindersToggled,
            ),
          ),
          if (_smartRemindersEnabled) ...[
            SettingsExpandedTile(
              icon: Icons.repeat,
              title: l10n.maxRemindersPerDay,
              subtitle: l10n.maxRemindersPerDayDescription,
              control: Slider(
                value: _maxSmartRemindersPerDay.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _maxSmartRemindersPerDay.toString(),
                onChanged: (value) {
                  final intValue = value.round();
                  setState(() {
                    _maxSmartRemindersPerDay = intValue;
                    ref.read(settingsProvider).activeUserSettings
                        .notificationSettings.maxSmartRemindersPerDay = intValue;
                  });
                  _autoSave();
                  _rescheduleSmartReminders();
                },
              ),
            ),
            SettingsTile(
              icon: Icons.bedtime_outlined,
              title: l10n.quietHoursStart,
              subtitle: l10n.quietHoursDescription,
              trailing: _TimeChip(time: _quietHoursStart, context: context),
              onTap: _selectQuietHoursStart,
            ),
            SettingsTile(
              icon: Icons.wb_sunny_outlined,
              title: l10n.quietHoursEnd,
              trailing: _TimeChip(time: _quietHoursEnd, context: context),
              onTap: _selectQuietHoursEnd,
            ),
          ],
          SettingsTile(
            icon: Icons.local_fire_department_outlined,
            title: l10n.streakWarnings,
            subtitle: l10n.streakWarningsDescription,
            trailing: Switch(
              value: _streakWarningsEnabled,
              onChanged: (value) {
                setState(() {
                  _streakWarningsEnabled = value;
                  ref.read(settingsProvider).activeUserSettings.notificationSettings
                      .streakWarningsEnabled = value;
                });
                _autoSave();
              },
            ),
          ),
          SettingsTile(
            icon: Icons.auto_awesome,
            title: l10n.weeklyReviewNotification,
            subtitle: l10n.weeklyReviewDescription,
            trailing: Switch(
              value: _weeklyReviewEnabled,
              onChanged: _onWeeklyReviewToggled,
            ),
          ),
          if (_weeklyReviewEnabled) ...[
            SettingsTile(
              icon: Icons.calendar_today,
              title: l10n.weeklyReviewDay,
              trailing: DropdownButton<int>(
                value: _weeklyReviewDay,
                underline: const SizedBox.shrink(),
                items: List.generate(7, (i) {
                  final day = i + 1;
                  return DropdownMenuItem(
                    value: day,
                    child: Text(_dayName(day, l10n)),
                  );
                }),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _weeklyReviewDay = value;
                    ref.read(settingsProvider).activeUserSettings
                        .notificationSettings.weeklyReviewDay = value;
                  });
                  _autoSave();
                  _rescheduleSmartReminders();
                },
              ),
            ),
            SettingsTile(
              icon: Icons.access_time,
              title: l10n.weeklyReviewTime,
              trailing: _TimeChip(time: _weeklyReviewTime, context: context),
              onTap: _selectWeeklyReviewTime,
            ),
          ],
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
      ref.read(settingsProvider).activeUserSettings.notificationSettings.enabled = value;
    });
    _autoSave();

    if (value) {
      await _notificationService.scheduleDailyReminder(
        ref.read(settingsProvider).activeUserSettings.notificationSettings,
      );
      LogWrapper.logger.i('Notifications enabled and scheduled');
    } else {
      await _notificationService.cancelAllNotifications();
      LogWrapper.logger.i('Notifications disabled and cancelled');
    }
  }

  void _onSmartRemindersToggled(bool value) {
    setState(() {
      _smartRemindersEnabled = value;
      ref.read(settingsProvider).activeUserSettings.notificationSettings
          .smartRemindersEnabled = value;
    });
    _autoSave();
    _rescheduleSmartReminders();
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
        ref.read(settingsProvider).activeUserSettings.notificationSettings.reminderTime =
            picked;
      });
      _autoSave();

      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          ref.read(settingsProvider).activeUserSettings.notificationSettings,
        );
      }
    }
  }

  Future<void> _selectQuietHoursStart() async {
    final l10n = AppLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _quietHoursStart,
      helpText: l10n.selectQuietHoursStart,
    );

    if (picked != null && picked != _quietHoursStart) {
      setState(() {
        _quietHoursStart = picked;
        ref.read(settingsProvider).activeUserSettings.notificationSettings
            .quietHoursStart = picked;
      });
      _autoSave();
      _rescheduleSmartReminders();
    }
  }

  Future<void> _selectQuietHoursEnd() async {
    final l10n = AppLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _quietHoursEnd,
      helpText: l10n.selectQuietHoursEnd,
    );

    if (picked != null && picked != _quietHoursEnd) {
      setState(() {
        _quietHoursEnd = picked;
        ref.read(settingsProvider).activeUserSettings.notificationSettings
            .quietHoursEnd = picked;
      });
      _autoSave();
      _rescheduleSmartReminders();
    }
  }

  void _onWeeklyReviewToggled(bool value) {
    setState(() {
      _weeklyReviewEnabled = value;
      ref.read(settingsProvider).activeUserSettings.notificationSettings
          .weeklyReviewEnabled = value;
    });
    _autoSave();
    _rescheduleSmartReminders();
  }

  Future<void> _selectWeeklyReviewTime() async {
    final l10n = AppLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _weeklyReviewTime,
      helpText: l10n.weeklyReviewTime,
    );

    if (picked != null && picked != _weeklyReviewTime) {
      setState(() {
        _weeklyReviewTime = picked;
        ref.read(settingsProvider).activeUserSettings.notificationSettings
            .weeklyReviewTime = picked;
      });
      _autoSave();
      _rescheduleSmartReminders();
    }
  }

  String _dayName(int day, AppLocalizations l10n) {
    switch (day) {
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      case 7: return l10n.sunday;
      default: return '';
    }
  }

  /// Re-register the Workmanager task with updated settings.
  Future<void> _rescheduleSmartReminders() async {
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(
        ref.read(settingsProvider).activeUserSettings.notificationSettings,
      );
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
