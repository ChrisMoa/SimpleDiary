import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* light themes -----------------------------------------------------------------------------------------------------------------------------------

var lightBaseColor = const Color.fromARGB(255, 16, 188, 0);

var _lightColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: lightBaseColor,
);

var lightTheme = ThemeData().copyWith(
  colorScheme: _lightColorScheme,
  textTheme: GoogleFonts.latoTextTheme(),
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
