import 'package:SimpleDiary/model/Settings/settings.dart';
import 'package:SimpleDiary/model/Settings/setting_parameter.dart';
import 'package:flutter/foundation.dart';

class UserSettings extends Settings {  
  bool debugMode = kDebugMode;
  SettingsParameter<String> lastLoggedInUsername = SettingsParameter<String>('');

  @override
  Future<void> fromMap(Map<String, dynamic> map) async {
    if(map.containsKey('lastLoggedInUsername')){
      lastLoggedInUsername = SettingsParameter<String>(map['lastLoggedInUsername']);
    } else {
      
    }
    // Add other parameters here
  }

  @override
  Future<Map<String, dynamic>> toMap() async {
    Map<String, dynamic> map = {
      // add initializer list here
      'lastLoggedInUsername' : lastLoggedInUsername.value,
    };
    // map.addAll(userData.value.toMap());
    return map;
  }
  
  @override
  String get name => 'UserSettings';
}