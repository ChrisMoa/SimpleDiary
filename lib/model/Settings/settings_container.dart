import 'package:SimpleDiary/model/Settings/path_settings.dart';
import 'package:SimpleDiary/model/Settings/settings.dart';
import 'package:SimpleDiary/model/Settings/user_settings.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsContainer {
  final _sharedPreferenceStorage = const FlutterSecureStorage();
  var userSettings = UserSettings();
  var pathSettings = PathSettings();
  List<Settings> settings = [];

  SettingsContainer() {
    settings.add(userSettings);
    settings.add(pathSettings);
  }

  Future<void> readSettings() async {
    var overallSettingsMap = await _sharedPreferenceStorage.readAll();
    for (var curSetting in settings) {
      try {
        await curSetting.fromMap(overallSettingsMap);
      } catch (e) {
        if (kDebugMode) {
          print('got error by reading ${curSetting.name}: $e');
        }
      }
    }
    if (kDebugMode) {
      print("read settings successfully");
    }
  }

  Future<void> saveSettings() async {
    LogWrapper.logger.i('saves settings');
    for (var curSetting in settings) {
      try {
        var settingMap = await curSetting.toMap();
        for (var entry in settingMap.entries) {
          await _sharedPreferenceStorage.write(key: entry.key, value: entry.value);
        }
      } catch (e) {
        LogWrapper.logger.e('got error by writing ${curSetting.name}: $e');
      }
    }
    LogWrapper.logger.d('saved settings');
  }
}

var settingsContainer = SettingsContainer();
