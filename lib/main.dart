import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/model/active_platform.dart';
import 'package:SimpleDiary/model/log/custom_log_printer.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/pages/main_page.dart';
import 'package:SimpleDiary/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await settingsContainer.readSettings();
  if (activePlatform.platform == ActivePlatform.windows || activePlatform.platform == ActivePlatform.linux) {
    //* Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  //* init logger
  bool debugging = settingsContainer.userSettings.debugMode;
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        darkTheme: darkTheme,
        theme: lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: settingsContainer.userSettings.debugMode,
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
