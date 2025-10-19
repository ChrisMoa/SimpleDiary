import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider()
      : super(() {
          final initialColorScheme = ColorScheme.fromSeed(
            brightness: settingsContainer.activeUserSettings.darkThemeMode
                ? Brightness.dark
                : Brightness.light,
            seedColor: settingsContainer.activeUserSettings.themeSeedColor,
          );
          return lightTheme.copyWith(
            colorScheme: initialColorScheme,
            cardTheme: CardThemeData(
              color: initialColorScheme.surface,
              elevation: 1,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          );
        }());
  bool darkMode = false;
  Color _seedColor = settingsContainer.activeUserSettings.themeSeedColor;

  ///
  /// @brief updates the theme value depending on the newThemeColor and darkMode
  /// @param [newThemeColor] the new theme seed color that will be applied
  /// @param [darkMode] has to be set to apply either darkMode or lightMode
  /// @return void
  ///
  void updateThemeFromSeedColor(Color newThemeColor) {
    LogWrapper.logger
        .t('updates themeColor to ${Utils.colorToRGBInt(newThemeColor)}');
    
    final newColorScheme = ColorScheme.fromSeed(
      brightness: darkMode ? Brightness.dark : Brightness.light,
      seedColor: newThemeColor,
    );
    
    var newTheme = lightTheme.copyWith(
      colorScheme: newColorScheme,
      cardTheme: CardThemeData(
        color: newColorScheme.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );

    _seedColor = newThemeColor;
    state = newTheme;
  }

  ///
  /// @brief updates the theme value depending on the newThemeColor and darkMode
  /// @param [darkMode] has to be set to apply either darkMode or lightMode
  /// @return void
  ///
  void toggleDarkMode(bool darkMode) {
    LogWrapper.logger.t('toggles between dark and light mode');
    this.darkMode = darkMode;
    
    final newColorScheme = ColorScheme.fromSeed(
      brightness: darkMode ? Brightness.dark : Brightness.light,
      seedColor: _seedColor,
    );
    
    var newTheme = lightTheme.copyWith(
      colorScheme: newColorScheme,
      cardTheme: CardThemeData(
        color: newColorScheme.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
    state = newTheme;
  }

  Color get seedColor {
    return _seedColor;
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>(
  (ref) => ThemeProvider(),
);
