// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';

class UserSettings {
  bool darkThemeMode;
  Color themeSeedColor;
  UserData savedUserData;
  SupabaseSettings supabaseSettings;
  String languageCode;

  UserSettings(
    this.darkThemeMode,
    this.themeSeedColor,
    this.savedUserData,
    this.supabaseSettings,
    this.languageCode,
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'darkThemeMode': darkThemeMode,
      'themeSeedColor': themeSeedColor.value,
      'userData': savedUserData.toMap(),
      'supabaseSettings': supabaseSettings.toMap(),
      'languageCode': languageCode,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      map['darkThemeMode'] as bool,
      Color(map['themeSeedColor'] as int),
      UserData.fromMap(map['userData']),
      SupabaseSettings.fromMap(map['supabaseSettings'] ?? {}),
      (map['languageCode'] as String?) ?? 'en',
    );
  }

  factory UserSettings.fromEmpty() => UserSettings(
        false,
        lightBaseColor,
        UserData.fromEmpty(),
        SupabaseSettings.empty(),
        'en',
      );

  String get name => 'UserSettings';
  String toJson() => json.encode(toMap());

  factory UserSettings.fromJson(String source) => UserSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
