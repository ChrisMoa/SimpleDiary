import 'package:day_tracker/core/settings/biometric_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiometricSettings', () {
    test('fromEmpty creates valid defaults', () {
      final settings = BiometricSettings.fromEmpty();

      expect(settings.isEnabled, false);
      expect(settings.requireOnResume, false);
      expect(settings.lockTimeoutMinutes, 5);
    });

    test('toMap serializes all fields', () {
      final settings = BiometricSettings(
        isEnabled: true,
        requireOnResume: true,
        lockTimeoutMinutes: 15,
      );

      final map = settings.toMap();

      expect(map['isEnabled'], true);
      expect(map['requireOnResume'], true);
      expect(map['lockTimeoutMinutes'], 15);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'isEnabled': true,
        'requireOnResume': true,
        'lockTimeoutMinutes': 10,
      };

      final settings = BiometricSettings.fromMap(map);

      expect(settings.isEnabled, true);
      expect(settings.requireOnResume, true);
      expect(settings.lockTimeoutMinutes, 10);
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};

      final settings = BiometricSettings.fromMap(map);

      expect(settings.isEnabled, false);
      expect(settings.requireOnResume, false);
      expect(settings.lockTimeoutMinutes, 5);
    });

    test('round-trip through JSON preserves data', () {
      final original = BiometricSettings(
        isEnabled: true,
        requireOnResume: true,
        lockTimeoutMinutes: 0,
      );

      final json = original.toJson();
      final restored = BiometricSettings.fromJson(json);

      expect(restored.isEnabled, original.isEnabled);
      expect(restored.requireOnResume, original.requireOnResume);
      expect(restored.lockTimeoutMinutes, original.lockTimeoutMinutes);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = BiometricSettings.fromEmpty();

      final updated = original.copyWith(
        isEnabled: true,
        lockTimeoutMinutes: 1,
      );

      expect(updated.isEnabled, true);
      expect(updated.lockTimeoutMinutes, 1);
      expect(updated.requireOnResume, original.requireOnResume);
    });

    test('copyWith with no arguments creates identical copy', () {
      final original = BiometricSettings(
        isEnabled: true,
        requireOnResume: true,
        lockTimeoutMinutes: 15,
      );

      final copy = original.copyWith();

      expect(copy.isEnabled, original.isEnabled);
      expect(copy.requireOnResume, original.requireOnResume);
      expect(copy.lockTimeoutMinutes, original.lockTimeoutMinutes);
    });

    test('toString contains all fields', () {
      final settings = BiometricSettings(
        isEnabled: true,
        requireOnResume: false,
        lockTimeoutMinutes: 5,
      );

      final str = settings.toString();

      expect(str, contains('isEnabled: true'));
      expect(str, contains('requireOnResume: false'));
      expect(str, contains('lockTimeoutMinutes: 5'));
    });

    test('map contains all required keys', () {
      final settings = BiometricSettings.fromEmpty();
      final map = settings.toMap();

      expect(map.keys, containsAll([
        'isEnabled',
        'requireOnResume',
        'lockTimeoutMinutes',
      ]));
    });

    test('lockTimeoutMinutes zero means immediate lock', () {
      final settings = BiometricSettings(
        isEnabled: true,
        requireOnResume: true,
        lockTimeoutMinutes: 0,
      );

      expect(settings.lockTimeoutMinutes, 0);
      final map = settings.toMap();
      final restored = BiometricSettings.fromMap(map);
      expect(restored.lockTimeoutMinutes, 0);
    });
  });
}
