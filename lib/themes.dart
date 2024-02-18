import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* light themes -----------------------------------------------------------------------------------------------------------------------------------

var _lightColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 16, 188, 0),
);

var lightTheme = ThemeData().copyWith(
  colorScheme: _lightColorScheme,
  textTheme: GoogleFonts.latoTextTheme(),
  appBarTheme: const AppBarTheme().copyWith(backgroundColor: _lightColorScheme.primary, foregroundColor: _lightColorScheme.primaryContainer),
  cardTheme: const CardTheme().copyWith(
    color: _lightColorScheme.secondaryContainer,
    margin: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primaryContainer,
    ),
  ),
);

//* dark themes -----------------------------------------------------------------------------------------------------------------------------------

var _darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 0, 56, 188),
);

var darkTheme = ThemeData.dark().copyWith(
  colorScheme: _darkColorScheme,
  textTheme: GoogleFonts.latoTextTheme(),
  appBarTheme: const AppBarTheme().copyWith(backgroundColor: _darkColorScheme.primary, foregroundColor: _darkColorScheme.primaryContainer),
  cardTheme: const CardTheme().copyWith(
    color: _darkColorScheme.secondaryContainer,
    margin: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
    ),
  ),
);

// var _lightColorScheme1 = ColorScheme.fromSeed(
//   brightness: Brightness.light,
//   seedColor: Colors.lightGreen,
// );

// var _lightColorScheme2 = ColorScheme.fromSeed(
//   brightness: Brightness.light,
//   seedColor: const Color.fromARGB(255, 255, 0, 106),
// );

// var _lightColorScheme3 = ColorScheme.fromSeed(
//   brightness: Brightness.light,
//   seedColor: const Color.fromARGB(255, 47, 0, 255),
// );