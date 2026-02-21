import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider()
      : super(_buildTheme(
          seedColor: settingsContainer.activeUserSettings.themeSeedColor,
          isDark: settingsContainer.activeUserSettings.darkThemeMode,
        ));
  bool darkMode = false;
  Color _seedColor = settingsContainer.activeUserSettings.themeSeedColor;

  static ThemeData _buildTheme({
    required Color seedColor,
    required bool isDark,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      brightness: isDark ? Brightness.dark : Brightness.light,
      seedColor: seedColor,
    );
    return lightTheme.copyWith(
      colorScheme: colorScheme,
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

  void updateThemeFromSeedColor(Color newThemeColor) {
    LogWrapper.logger
        .t('updates themeColor to ${Utils.colorToRGBInt(newThemeColor)}');

    _seedColor = newThemeColor;
    state = _buildTheme(seedColor: _seedColor, isDark: darkMode);
  }

  void toggleDarkMode(bool darkMode) {
    LogWrapper.logger.t('toggles between dark and light mode');
    this.darkMode = darkMode;

    state = _buildTheme(seedColor: _seedColor, isDark: darkMode);
  }

  Color get seedColor {
    return _seedColor;
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>(
  (ref) => ThemeProvider(),
);
