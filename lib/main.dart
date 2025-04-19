import 'package:day_tracker/core/log/custom_log_printer.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/features/app/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//* main() -------------------------------------------------------------------------------------------------------------------------------------

void main() async {
  await dotenv.load(fileName: ".env");
  if (activePlatform.platform == ActivePlatform.android) {
    await Permission.manageExternalStorage.request();
  }
  await settingsContainer.readSettings();
  if (activePlatform.platform == ActivePlatform.windows ||
      activePlatform.platform == ActivePlatform.linux) {
    //* Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  //* init logger
  bool debugging = settingsContainer.debugMode;
  LogWrapper.logger = Logger(
    level: debugging ? Level.trace : Level.info,
    output: FileOutput(
      file: await LogWrapper.createLogfile(),
    ),
    printer: CustomLogPrinter(),
  );

  //* run
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

//* MyApp-> -------------------------------------------------------------------------------------------------------------------------------------

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ref.watch(themeProvider),
        debugShowCheckedModeBanner: settingsContainer.debugMode,
        home: const MainPage(
          title: 'Simple Diary',
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('de'), Locale('en')],
      );
}

//* <-MyApp -------------------------------------------------------------------------------------------------------------------------------------
