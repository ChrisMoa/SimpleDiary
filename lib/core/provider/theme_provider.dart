import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider(SettingsContainer settings)
      : _seedColor = settings.activeUserSettings.themeSeedColor,
        darkMode = settings.activeUserSettings.darkThemeMode,
        super(buildAppTheme(
          seedColor: settings.activeUserSettings.themeSeedColor,
          isDark: settings.activeUserSettings.darkThemeMode,
        ));
  bool darkMode;
  Color _seedColor;

  void updateThemeFromSeedColor(Color newThemeColor) {
    LogWrapper.logger
        .t('updates themeColor to ${Utils.colorToRGBInt(newThemeColor)}');

    _seedColor = newThemeColor;
    state = buildAppTheme(seedColor: _seedColor, isDark: darkMode);
  }

  void toggleDarkMode(bool darkMode) {
    LogWrapper.logger.t('toggles between dark and light mode');
    this.darkMode = darkMode;

    state = buildAppTheme(seedColor: _seedColor, isDark: darkMode);
  }

  Color get seedColor {
    return _seedColor;
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>(
  (ref) => ThemeProvider(ref.read(settingsProvider)),
);
