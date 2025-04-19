import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider()
      : super(lightTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
            brightness: settingsContainer.activeUserSettings.darkThemeMode
                ? Brightness.dark
                : Brightness.light,
            seedColor: settingsContainer.activeUserSettings.themeSeedColor,
          ),
        ));
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
    var newTheme = lightTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        seedColor: newThemeColor,
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
    var newTheme = lightTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        seedColor: _seedColor,
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
