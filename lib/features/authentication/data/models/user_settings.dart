// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:day_tracker/core/settings/backup_settings.dart';
import 'package:day_tracker/core/settings/biometric_settings.dart';
import 'package:day_tracker/core/settings/notification_settings.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';

class UserSettings {
  bool darkThemeMode;
  Color themeSeedColor;
  UserData savedUserData;
  SupabaseSettings supabaseSettings;
  String languageCode;
  NotificationSettings notificationSettings;
  BiometricSettings biometricSettings;
  BackupSettings backupSettings;

  UserSettings(
    this.darkThemeMode,
    this.themeSeedColor,
    this.savedUserData,
    this.supabaseSettings,
    this.languageCode,
    this.notificationSettings,
    this.biometricSettings,
    this.backupSettings,
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'darkThemeMode': darkThemeMode,
      'themeSeedColor': themeSeedColor.value,
      'userData': savedUserData.toMap(),
      'supabaseSettings': supabaseSettings.toMap(),
      'languageCode': languageCode,
      'notificationSettings': notificationSettings.toMap(),
      'biometricSettings': biometricSettings.toMap(),
      'backupSettings': backupSettings.toMap(),
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      map['darkThemeMode'] as bool,
      Color(map['themeSeedColor'] as int),
      UserData.fromMap(map['userData']),
      SupabaseSettings.fromMap(map['supabaseSettings'] ?? {}),
      (map['languageCode'] as String?) ?? 'en',
      NotificationSettings.fromMap(map['notificationSettings'] ?? {}),
      BiometricSettings.fromMap(map['biometricSettings'] ?? {}),
      BackupSettings.fromMap(map['backupSettings'] ?? {}),
    );
  }

  factory UserSettings.fromEmpty() => UserSettings(
        false,
        lightBaseColor,
        UserData.fromEmpty(),
        SupabaseSettings.empty(),
        'en',
        NotificationSettings.fromEmpty(),
        BiometricSettings.fromEmpty(),
        BackupSettings.fromEmpty(),
      );

  String get name => 'UserSettings';
  String toJson() => json.encode(toMap());

  factory UserSettings.fromJson(String source) => UserSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
