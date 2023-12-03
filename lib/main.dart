import 'package:SimpleDiary/model/active_platform.dart';
import 'package:SimpleDiary/model/log/custom_log_printer.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 255, 251, 0),
  onBackground: const Color.fromARGB(255, 244, 248, 168),
  background: const Color.fromARGB(255, 247, 250, 195),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 2, 35, 180),
);

void main() async {
  await dotenv.load(fileName: ".env");
  if (activePlatform.platform == ActivePlatform.windows || activePlatform.platform == ActivePlatform.linux) {
    //* Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  //* init logger
  bool debugging = int.tryParse(dotenv.env['DEBUG_MODE'] ?? '1') == 1;
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
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
          colorScheme: kDarkColorScheme,
          textTheme: GoogleFonts.latoTextTheme(),
          cardTheme: const CardTheme().copyWith(
            color: kDarkColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkColorScheme.primaryContainer,
              foregroundColor: kDarkColorScheme.onPrimaryContainer,
            ),
          ),
        ),
        theme: ThemeData().copyWith(
          useMaterial3: true,
          colorScheme: kColorScheme,
          appBarTheme: const AppBarTheme().copyWith(backgroundColor: kColorScheme.onPrimaryContainer, foregroundColor: kColorScheme.primaryContainer),
          cardTheme: const CardTheme().copyWith(
            color: kColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorScheme.primaryContainer,
            ),
          ),
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        themeMode: ThemeMode.light,
        // home: const MainPage(
        //   title: 'Simple Diary',
        // ),

        debugShowCheckedModeBanner: int.tryParse(dotenv.env['DEBUG_MODE'] ?? '1') == 1,
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
