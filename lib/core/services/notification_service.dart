// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/diary_status_service.dart';
import 'package:day_tracker/core/services/smart_reminder_algorithm.dart';
import 'package:day_tracker/core/settings/notification_settings.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';

/// Notification ID for smart reminders (distinct from daily=0, streak=1)
const int _smartReminderNotificationId = 2;

/// Service for handling local notifications and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      LogWrapper.logger.d('NotificationService already initialized');
      return;
    }

    try {
      LogWrapper.logger.i('Initializing NotificationService');

      // Initialize timezone database
      tz.initializeTimeZones();
      // Set local timezone to device's timezone
      final String timeZoneName = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // If timezone name not found, try with Europe/Berlin or UTC
        LogWrapper.logger.w('Timezone $timeZoneName not found, using local default');
      }

      // Initialize notifications plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: LinuxInitializationSettings(defaultActionName: 'Open notification'),
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      const androidChannel = AndroidNotificationChannel(
        'diary_reminders',
        'Diary Reminders',
        description: 'Daily reminders to write diary entries',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Initialize Workmanager for background tasks (Android only)
      if (activePlatform.platform == ActivePlatform.android) {
        await Workmanager().initialize(
          _callbackDispatcher,
          isInDebugMode: false,
        );
      }

      _isInitialized = true;
      LogWrapper.logger.i('NotificationService initialized successfully');
    } catch (e) {
      LogWrapper.logger.e('Failed to initialize NotificationService: $e');
      // Don't rethrow — missing plugin on desktop is non-fatal
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      LogWrapper.logger.d('Requesting notification permissions');

      // Request notification permission
      final notificationStatus = await Permission.notification.request();

      if (!notificationStatus.isGranted) {
        LogWrapper.logger.w('Notification permission denied');
        return false;
      }

      LogWrapper.logger.i('Notification permission granted');

      // Request exact alarm permission (required for Android 12+)
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();

      if (!exactAlarmStatus.isGranted) {
        LogWrapper.logger.w('Exact alarm permission denied');
        return false;
      }

      LogWrapper.logger.i('Exact alarm permission granted');
      return true;
    } catch (e) {
      LogWrapper.logger.e('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if notification permissions are granted
  Future<bool> hasPermissions() async {
    return await Permission.notification.isGranted;
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder(NotificationSettings settings) async {
    if (!settings.enabled) {
      LogWrapper.logger.d('Notifications disabled, skipping scheduling');
      return;
    }

    if (!_isInitialized) {
      LogWrapper.logger.w('NotificationService not initialized, cannot schedule');
      return;
    }

    try {
      LogWrapper.logger.i('Scheduling daily reminder at ${settings.reminderTime}');

      // Cancel existing notifications
      await cancelAllNotifications();

      final time = settings.reminderTime;
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        0, // Notification ID
        'Time for your diary entry! 📝',
        'Don\'t forget to write about your day',
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
      );

      // Register background task for smart reminders (Android only)
      if (settings.smartRemindersEnabled &&
          activePlatform.platform == ActivePlatform.android) {
        await Workmanager().registerPeriodicTask(
          'diary_reminder_check',
          'diary_reminder_check',
          frequency: const Duration(hours: 1),
          inputData: {
            'maxReminders': settings.maxSmartRemindersPerDay,
            'quietHoursStart': settings.quietHoursStartMinutes,
            'quietHoursEnd': settings.quietHoursEndMinutes,
          },
          constraints: Constraints(
            networkType: NetworkType.not_required,
          ),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }

      LogWrapper.logger.i('Daily reminder scheduled successfully');
    } catch (e) {
      LogWrapper.logger.e('Error scheduling daily reminder: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      if (activePlatform.platform == ActivePlatform.android) {
        await Workmanager().cancelAll();
      }
      LogWrapper.logger.i('All notifications cancelled');
    } catch (e) {
      LogWrapper.logger.e('Error cancelling notifications: $e');
    }
  }

  /// Show immediate notification for streak warning
  Future<void> showStreakWarning(int currentStreak) async {
    if (!_isInitialized) return;

    try {
      await _notificationsPlugin.show(
        1, // Different ID for streak warnings
        'Keep your streak alive! 🔥',
        'You have a $currentStreak day streak. Don\'t break it!',
        _notificationDetails(),
      );
      LogWrapper.logger.i('Streak warning notification shown');
    } catch (e) {
      LogWrapper.logger.e('Error showing streak warning: $e');
    }
  }

  /// Notification details configuration
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'diary_reminders',
        'Diary Reminders',
        channelDescription: 'Daily reminders to write diary entries',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    LogWrapper.logger.d('Notification tapped: ${response.payload}');
    // TODO: Navigate to diary entry page when notification is tapped
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Background isolate needs its own binding
      WidgetsFlutterBinding.ensureInitialized();

      switch (task) {
        case 'diary_reminder_check':
          await _checkAndSendSmartReminder(inputData);
          break;

        case 'scheduled_backup':
          // Background backup runs with limited context on Android.
          // The actual backup with full data is performed on next app open
          // via BackupScheduler.checkAndRunOverdueBackup().
          break;

        default:
          LogWrapper.logger.w('Unknown background task: $task');
      }

      return Future.value(true);
    } catch (e) {
      LogWrapper.logger.e('Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Check diary status and send a smart reminder notification if appropriate.
Future<void> _checkAndSendSmartReminder(Map<String, dynamic>? inputData) async {
  final maxReminders = inputData?['maxReminders'] as int? ?? 3;
  final quietHoursStart = inputData?['quietHoursStart'] as int? ?? 22 * 60;
  final quietHoursEnd = inputData?['quietHoursEnd'] as int? ?? 8 * 60;

  final hasEntry = await DiaryStatusService.hasEntryForToday();
  final remindersSent = await DiaryStatusService.getRemindersSentToday();

  final shouldSend = SmartReminderAlgorithm.shouldSendReminder(
    now: DateTime.now(),
    hasEntryToday: hasEntry,
    remindersSentToday: remindersSent,
    maxRemindersPerDay: maxReminders,
    quietHoursStartMinutes: quietHoursStart,
    quietHoursEndMinutes: quietHoursEnd,
  );

  if (!shouldSend) return;

  final intensity = SmartReminderAlgorithm.calculateIntensity(remindersSent);

  // Initialize notifications plugin for the background isolate
  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await plugin.initialize(initSettings);

  final (title, body) = _reminderMessage(intensity);

  await plugin.show(
    _smartReminderNotificationId,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'diary_reminders',
        'Diary Reminders',
        channelDescription: 'Daily reminders to write diary entries',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );

  await DiaryStatusService.incrementReminderCount();
  LogWrapper.logger.i('Smart reminder sent (intensity: ${intensity.name})');
}

/// Get notification title and body for the given intensity.
(String title, String body) _reminderMessage(ReminderIntensity intensity) {
  switch (intensity) {
    case ReminderIntensity.gentle:
      return (
        'Time to reflect on your day',
        'Take a moment to capture your thoughts and experiences.',
      );
    case ReminderIntensity.normal:
      return (
        'Don\'t forget your diary entry today',
        'You haven\'t written your entry yet. How was your day?',
      );
    case ReminderIntensity.urgent:
      return (
        'Last chance to capture today\'s memories!',
        'The day is almost over — write a quick entry before it slips away.',
      );
  }
}
