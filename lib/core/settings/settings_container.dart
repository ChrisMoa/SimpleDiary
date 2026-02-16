import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class SettingsContainer {
  UserSettings activeUserSettings = UserSettings.fromEmpty();
  String lastLoggedInUsername = '';
  List<UserSettings> userSettings = [];

  bool debugMode = kDebugMode;
  final String projectName = dotenv.env['PROJECT_NAME'] ?? 'day_tracker';
  String applicationDocumentsPath = '';
  String applicationExternalDocumentsPath = '';

  Future<void> readSettings() async {
    applicationDocumentsPath = await _readAppDocumentsPath();

    // create the external documents storage
    applicationExternalDocumentsPath = await _readAppExternalDocumentsPath();
    var applicationExternalDocumentsDir =
        Directory(applicationExternalDocumentsPath);
    if (!applicationExternalDocumentsDir.existsSync()) {
      applicationExternalDocumentsDir.createSync(recursive: true);
    }

    // read base settings
    File settingsFile = File('$applicationDocumentsPath/settings.json');
    Map<String, dynamic> settingsAsJson = {};
    if (!settingsFile.existsSync()) {
      if (kDebugMode) {
        print("creates settingsfile");
      }
      settingsFile.createSync(recursive: true);
      userSettings = [UserSettings.fromEmpty()];
    } else {
      final fileContent = settingsFile.readAsStringSync();
      if (fileContent.isNotEmpty) {
        settingsAsJson = json.decode(fileContent);
      } else {
        // Handle empty settings file (treat as new)
        userSettings = [UserSettings.fromEmpty()];
      }
    }
    lastLoggedInUsername = settingsAsJson['lastLoggedInUsername'] ?? '';

    // read active user settings
    if (settingsAsJson.isNotEmpty) {
      for (var curUserSettings in settingsAsJson['Users']) {
        userSettings.add(UserSettings.fromJson(curUserSettings));
      }
      activeUserSettings = getUserSettings(lastLoggedInUsername);
    }
    if (kDebugMode && userSettings.isEmpty) {
      // ignore: avoid_print
      print("settings file has no user settings in it");
    }
    if (kDebugMode) {
      print("read settings successfully");
    }
  }

  Future<void> saveSettings() async {
    LogWrapper.logger.i('saves settings');

    var existingUserIndex = userSettings
        .indexWhere((userSetting) => userSetting == activeUserSettings);
    if (existingUserIndex != -1) {
      userSettings[existingUserIndex] = activeUserSettings;
    }

    Map<String, dynamic> settingsAsJson = {
      'lastLoggedInUsername': lastLoggedInUsername,
      'Users': userSettings.map((userSetting) => userSetting.toJson()).toList(),
    };
    File settingsFile = File('$applicationDocumentsPath/settings.json');
    settingsFile.writeAsStringSync(json.encode(settingsAsJson));
    LogWrapper.logger.d('saved settings');
  }

  UserSettings getUserSettings([String? username]) {
    var usedUsername = username ?? lastLoggedInUsername;
    return userSettings.firstWhere(
        (userSetting) => userSetting.savedUserData.username == usedUsername);
  }

  bool checkIfUserExists(String username) {
    return userSettings
        .any((userSetting) => userSetting.savedUserData.username == username);
  }

  //* private methods --------------------------------------------------------------------------------------------------------------------------------------

  Future<String> _readAppDocumentsPath() async {
    var addAppPath = dotenv.env['PROJECT_NAME'] ?? 'day_tracker';
    return '${(await getApplicationDocumentsDirectory()).path}/$addAppPath';
  }

  Future<String> _readAppExternalDocumentsPath() async {
    var addAppPath = dotenv.env['PROJECT_NAME'] ?? 'day_tracker';
    switch (activePlatform.platform) {
      case ActivePlatform.ios:
      case ActivePlatform.android:
        return '/storage/emulated/0/$addAppPath';
      case ActivePlatform.linux:
      case ActivePlatform.windows:
        return await _readAppDocumentsPath();
      default:
        throw Exception('platform not supported');
    }
  }
}

var settingsContainer = SettingsContainer();
