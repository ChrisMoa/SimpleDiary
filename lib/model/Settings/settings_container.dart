import 'dart:convert';
import 'dart:io';
import 'package:SimpleDiary/model/active_platform.dart';
import 'package:SimpleDiary/model/user/user_settings.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class SettingsContainer {
  UserSettings activeUserSettings = UserSettings.fromEmpty();
  String lastLoggedInUsername = '';
  List<UserSettings> userSettings = [];

  bool debugMode = kDebugMode;
  final String projectName = dotenv.env['PROJECT_NAME'] ?? 'SimpleDiary';
  String applicationDocumentsPath = '';

  Future<void> readSettings() async {
    applicationDocumentsPath = await _readAppDocumentsPath();

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
      settingsAsJson = json.decode(settingsFile.readAsStringSync());
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

    var existingUserIndex = userSettings.indexWhere((userSetting) => userSetting == activeUserSettings);
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
    return userSettings.firstWhere((userSetting) => userSetting.savedUserData.username == usedUsername);
  }

  bool checkIfUserExists(String username) {
    return userSettings.any((userSetting) => userSetting.savedUserData.username == username);
  }

  //* private methods --------------------------------------------------------------------------------------------------------------------------------------

  Future<String> _readAppDocumentsPath() async {
    switch (activePlatform.platform) {
      case ActivePlatform.ios:
      case ActivePlatform.android:
        return '/storage/emulated/0/${dotenv.env['PROJECT_NAME'] ?? 'SimpleDiary'}';
      case ActivePlatform.linux:
      case ActivePlatform.windows:
        var addAppPath = dotenv.env['PROJECT_NAME'] ?? 'SimpleDiary';
        return '${(await getApplicationDocumentsDirectory()).path}/$addAppPath';
      default:
        throw Exception('platform not supported');
    }
  }
}

var settingsContainer = SettingsContainer();
