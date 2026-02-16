import 'package:day_tracker/core/log/custom_log_printer.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/services/notification_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/features/app/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//* main() -------------------------------------------------------------------------------------------------------------------------------------

void main() async {
  LogWrapper.logger.i('Starting application initialization');

  try {
    LogWrapper.logger.d('Loading environment variables');
    await dotenv.load(fileName: ".env");

    if (activePlatform.platform == ActivePlatform.android) {
      LogWrapper.logger.d('Requesting external storage permission for Android');
      await Permission.manageExternalStorage.request();
    }

    LogWrapper.logger.d('Reading application settings');
    await settingsContainer.readSettings();

    if (activePlatform.platform == ActivePlatform.windows || activePlatform.platform == ActivePlatform.linux) {
      LogWrapper.logger.d('Initializing FFI for desktop platform');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    //* init logger
    bool debugging = settingsContainer.debugMode;
    LogWrapper.logger = Logger(
      level: debugging ? Level.trace : Level.info,
      output: ConsoleOutput(),
      printer: CustomLogPrinter(),
    );
    LogWrapper.logger.i('Logger initialized with level: ${debugging ? 'trace' : 'info'}');

    //* init notification service
    LogWrapper.logger.d('Initializing NotificationService');
    await NotificationService().initialize();

    // Schedule notifications if enabled
    final notificationSettings = settingsContainer.activeUserSettings.notificationSettings;
    if (notificationSettings.enabled) {
      LogWrapper.logger.d('Scheduling notifications (enabled in settings)');
      await NotificationService().scheduleDailyReminder(notificationSettings);
    }

    LogWrapper.logger.i('Initialization complete, starting application');
    //* run
    runApp(
      const ProviderScope(child: MyApp()),
    );
  } catch (e) {
    LogWrapper.logger.e('Failed to initialize application: $e');
    rethrow;
  }
}

//* MyApp-> -------------------------------------------------------------------------------------------------------------------------------------

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    LogWrapper.logger.d('Initializing MyApp state');
  }

  @override
  Widget build(BuildContext context) {
    LogWrapper.logger.d('Building MyApp');
    return MaterialApp(
      theme: ref.watch(themeProvider),
      debugShowCheckedModeBanner: settingsContainer.debugMode,
      home: const MainPage(
        title: 'Simple Diary',
      ),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

//* <-MyApp -------------------------------------------------------------------------------------------------------------------------------------
