import 'dart:io';
import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for LocaleProvider state management
void main() {
  group('LocaleProvider', () {
    setUpAll(() async {
      // Initialize dotenv for settingsContainer
      // Create a minimal .env file if it doesn't exist
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        await envFile.writeAsString('# Test environment\n');
      }
      await dotenv.load(fileName: '.env');

      // Initialize settings
      await settingsContainer.readSettings();
    });

    setUp(() {
      // Reset to default language before each test
      settingsContainer.activeUserSettings.languageCode = 'en';
    });

    test('initial locale matches settings', () {
      // Set language to German in settings
      settingsContainer.activeUserSettings.languageCode = 'de';

      final provider = LocaleProvider();

      expect(provider.state, equals(const Locale('de')));
    });

    test('initial locale defaults to English', () {
      settingsContainer.activeUserSettings.languageCode = 'en';

      final provider = LocaleProvider();

      expect(provider.state, equals(const Locale('en')));
    });

    test('setLocale updates state', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('de'));

      expect(provider.state, equals(const Locale('de')));
    });

    test('setLocale persists to settings', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('de'));

      expect(settingsContainer.activeUserSettings.languageCode, equals('de'));
    });

    test('setLocale to English', () {
      // Start with German
      settingsContainer.activeUserSettings.languageCode = 'de';
      final provider = LocaleProvider();

      // Switch to English
      provider.setLocale(const Locale('en'));

      expect(provider.state, equals(const Locale('en')));
      expect(settingsContainer.activeUserSettings.languageCode, equals('en'));
    });

    test('state updates trigger listeners', () {
      final provider = LocaleProvider();
      var listenerCalled = false;
      Locale? capturedLocale;

      provider.addListener((state) {
        listenerCalled = true;
        capturedLocale = state;
      });

      provider.setLocale(const Locale('de'));

      expect(listenerCalled, isTrue);
      expect(capturedLocale, equals(const Locale('de')));
    });

    test('languageCode property matches locale', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('de'));
      expect(provider.state.languageCode, equals('de'));

      provider.setLocale(const Locale('en'));
      expect(provider.state.languageCode, equals('en'));
    });

    test('handles unsupported locale gracefully', () {
      final provider = LocaleProvider();

      // Try to set an unsupported locale (should still work, but app might fallback)
      provider.setLocale(const Locale('fr'));

      expect(provider.state.languageCode, equals('fr'));
      expect(settingsContainer.activeUserSettings.languageCode, equals('fr'));
    });

    test('multiple locale changes preserve state', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('de'));
      expect(provider.state.languageCode, equals('de'));

      provider.setLocale(const Locale('en'));
      expect(provider.state.languageCode, equals('en'));

      provider.setLocale(const Locale('de'));
      expect(provider.state.languageCode, equals('de'));

      // Verify final state is persisted
      expect(settingsContainer.activeUserSettings.languageCode, equals('de'));
    });
  });
}
