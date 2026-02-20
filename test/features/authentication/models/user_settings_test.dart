import 'dart:convert';

import 'package:day_tracker/core/settings/biometric_settings.dart';
import 'package:day_tracker/core/settings/notification_settings.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings', () {
    UserSettings createSampleSettings() {
      return UserSettings(
        true,
        const Color(0xFF2196F3),
        UserData(
          username: 'testuser',
          password: 'hashed',
          salt: 'salt',
          email: 'test@test.com',
          userId: 'user-123',
        ),
        SupabaseSettings(
          supabaseUrl: 'http://localhost:8000',
          supabaseAnonKey: 'anon-key',
          email: 'supabase@test.com',
          password: 'supapass',
        ),
        'en',
        NotificationSettings.fromEmpty(),
        BiometricSettings.fromEmpty(),
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final settings = createSampleSettings();
        expect(settings.darkThemeMode, true);
        expect(settings.themeSeedColor, const Color(0xFF2196F3));
        expect(settings.savedUserData.username, 'testuser');
        expect(settings.supabaseSettings.supabaseUrl, 'http://localhost:8000');
      });

      test('fromEmpty creates valid defaults', () {
        final settings = UserSettings.fromEmpty();
        expect(settings.darkThemeMode, false);
        expect(settings.savedUserData.username, '');
        expect(settings.supabaseSettings.supabaseUrl, '');
        expect(settings.languageCode, 'en');
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleSettings();
        final map = original.toMap();
        final restored = UserSettings.fromMap(map);

        expect(restored.darkThemeMode, original.darkThemeMode);
        expect(restored.savedUserData.username,
            original.savedUserData.username);
        expect(restored.savedUserData.email, original.savedUserData.email);
        expect(restored.supabaseSettings.supabaseUrl,
            original.supabaseSettings.supabaseUrl);
      });

      test('map contains correct keys', () {
        final settings = createSampleSettings();
        final map = settings.toMap();

        expect(map, contains('darkThemeMode'));
        expect(map, contains('themeSeedColor'));
        expect(map, contains('userData'));
        expect(map, contains('supabaseSettings'));
      });

      test('handles missing supabaseSettings in fromMap', () {
        final map = {
          'darkThemeMode': false,
          'themeSeedColor': 0xFF000000,
          'userData': UserData.fromEmpty().toMap(),
          // no 'supabaseSettings'
        };
        final settings = UserSettings.fromMap(map);
        expect(settings.supabaseSettings.supabaseUrl, '');
      });

      test('round-trip preserves languageCode', () {
        final original = UserSettings(
          true,
          const Color(0xFF2196F3),
          UserData.fromEmpty(),
          SupabaseSettings.empty(),
          'de',
          NotificationSettings.fromEmpty(),
          BiometricSettings.fromEmpty(),
        );
        final map = original.toMap();
        final restored = UserSettings.fromMap(map);
        expect(restored.languageCode, 'de');
      });

      test('fromMap defaults languageCode to en when missing (backward compat)', () {
        final map = {
          'darkThemeMode': false,
          'themeSeedColor': 0xFF000000,
          'userData': UserData.fromEmpty().toMap(),
          'supabaseSettings': SupabaseSettings.empty().toMap(),
          // no 'languageCode' key - simulates old settings file
        };
        final settings = UserSettings.fromMap(map);
        expect(settings.languageCode, 'en');
      });

      test('map contains languageCode key', () {
        final settings = createSampleSettings();
        final map = settings.toMap();
        expect(map, contains('languageCode'));
        expect(map['languageCode'], 'en');
      });
    });

    group('toJson / fromJson (string serialization)', () {
      test('round-trip through JSON string', () {
        final original = createSampleSettings();
        final jsonStr = original.toJson();

        expect(() => json.decode(jsonStr), returnsNormally);

        final restored = UserSettings.fromJson(jsonStr);
        expect(restored.darkThemeMode, original.darkThemeMode);
        expect(restored.savedUserData.username,
            original.savedUserData.username);
        expect(restored.supabaseSettings.email,
            original.supabaseSettings.email);
      });
    });

    group('name property', () {
      test('returns UserSettings', () {
        final settings = createSampleSettings();
        expect(settings.name, 'UserSettings');
      });
    });
  });
}
