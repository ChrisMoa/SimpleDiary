import 'package:SimpleDiary/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider() : super(lightTheme);
  bool darkMode = false;

  ///
  /// @brief updates the theme value
  /// @param [newTheme] the new theme that will be applied
  /// @return void
  ///
  void updateTheme(ThemeData newTheme) {
    state = newTheme;
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>(
  (ref) => ThemeProvider(),
);
