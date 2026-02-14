import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleProvider extends StateNotifier<Locale> {
  LocaleProvider()
      : super(Locale(settingsContainer.activeUserSettings.languageCode));

  void setLocale(Locale locale) {
    state = locale;
    settingsContainer.activeUserSettings.languageCode = locale.languageCode;
  }
}

final localeProvider = StateNotifierProvider<LocaleProvider, Locale>(
  (ref) => LocaleProvider(),
);
