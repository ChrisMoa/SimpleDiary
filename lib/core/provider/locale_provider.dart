import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleProvider extends StateNotifier<Locale> {
  final SettingsContainer _settings;

  LocaleProvider(this._settings)
      : super(Locale(_settings.activeUserSettings.languageCode));

  void setLocale(Locale locale) {
    state = locale;
    _settings.activeUserSettings.languageCode = locale.languageCode;
  }
}

final localeProvider = StateNotifierProvider<LocaleProvider, Locale>(
  (ref) => LocaleProvider(ref.read(settingsProvider)),
);
