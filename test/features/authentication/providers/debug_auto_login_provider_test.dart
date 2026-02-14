import 'dart:io';

import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    // Load dotenv BEFORE creating SettingsContainer (constructor reads PROJECT_NAME)
    dotenv.testLoad(mergeWith: {
      'PROJECT_NAME': 'test_project',
    });
    // Create a temp directory for settings file
    tempDir = Directory.systemTemp.createTempSync('debug_auto_login_test_');
    // Reset the global settingsContainer
    settingsContainer = SettingsContainer();
    settingsContainer.applicationDocumentsPath = tempDir.path;
    settingsContainer.userSettings = [UserSettings.fromEmpty()];
    settingsContainer.lastLoggedInUsername = '';
    settingsContainer.activeUserSettings = UserSettings.fromEmpty();

    // Create the settings.json file so saveSettings works
    File('${tempDir.path}/settings.json').writeAsStringSync('{}');
  });

  tearDown(() {
    // Clean up temp directory
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('UserDataProvider.debugAutoLogin', () {
    test('creates user when debug user does not exist', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_AUTO_LOGIN': 'true',
        'DEBUG_USERNAME': 'testuser',
        'DEBUG_PASSWORD': 'testpass123',
        'DEBUG_EMAIL': 'test@test.com',
      });

      final provider = UserDataProvider();
      provider.debugAutoLogin();

      expect(provider.debugState.isLoggedIn, true);
      expect(provider.debugState.username, 'testuser');
      expect(provider.debugState.clearPassword, 'testpass123');
      expect(settingsContainer.checkIfUserExists('testuser'), true);
    });

    test('logs in existing debug user', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_AUTO_LOGIN': 'true',
        'DEBUG_USERNAME': 'testuser',
        'DEBUG_PASSWORD': 'testpass123',
        'DEBUG_EMAIL': 'test@test.com',
      });

      // First create the user
      final provider = UserDataProvider();
      provider.debugAutoLogin();
      expect(provider.debugState.isLoggedIn, true);

      // Create a new provider instance (simulates app restart)
      // The user now exists in settingsContainer
      settingsContainer.lastLoggedInUsername = 'testuser';
      final provider2 = UserDataProvider();
      // State loaded from settings but not logged in yet
      expect(provider2.debugState.isLoggedIn, false);

      provider2.debugAutoLogin();

      expect(provider2.debugState.isLoggedIn, true);
      expect(provider2.debugState.username, 'testuser');
      expect(provider2.debugState.clearPassword, 'testpass123');
    });

    test('does nothing when auto-login is disabled', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_AUTO_LOGIN': 'false',
        'DEBUG_USERNAME': 'testuser',
        'DEBUG_PASSWORD': 'testpass123',
      });

      final provider = UserDataProvider();
      provider.debugAutoLogin();

      expect(provider.debugState.isLoggedIn, false);
      expect(provider.debugState.username, isEmpty);
    });

    test('does nothing when DEBUG_AUTO_LOGIN is not set', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_USERNAME': 'testuser',
        'DEBUG_PASSWORD': 'testpass123',
      });

      final provider = UserDataProvider();
      provider.debugAutoLogin();

      expect(provider.debugState.isLoggedIn, false);
    });

    test('does nothing with invalid credentials (short password)', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_AUTO_LOGIN': 'true',
        'DEBUG_USERNAME': 'testuser',
        'DEBUG_PASSWORD': 'short',
      });

      final provider = UserDataProvider();
      provider.debugAutoLogin();

      expect(provider.debugState.isLoggedIn, false);
    });

    test('does nothing with empty username', () {
      dotenv.testLoad(mergeWith: {
        'PROJECT_NAME': 'test_project',
        'DEBUG_AUTO_LOGIN': 'true',
        'DEBUG_USERNAME': '',
        'DEBUG_PASSWORD': 'testpass123',
      });

      final provider = UserDataProvider();
      provider.debugAutoLogin();

      expect(provider.debugState.isLoggedIn, false);
    });
  });
}
