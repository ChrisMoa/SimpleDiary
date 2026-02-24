import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const defaultSeedColor = Color.fromARGB(255, 16, 188, 0);

ThemeData buildAppTheme({
  required Color seedColor,
  required bool isDark,
}) {
  final colorScheme = ColorScheme.fromSeed(
    brightness: isDark ? Brightness.dark : Brightness.light,
    seedColor: seedColor,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.latoTextTheme(),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
      ),
    ),
  );
}

final lightTheme = buildAppTheme(seedColor: defaultSeedColor, isDark: false);

