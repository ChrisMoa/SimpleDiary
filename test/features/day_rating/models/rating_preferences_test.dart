import 'package:day_tracker/features/day_rating/data/models/rating_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RatingPreferences', () {
    test('default values', () {
      const prefs = RatingPreferences();
      expect(prefs.mode, RatingMode.balanced);
      expect(prefs.showQuickMood, isTrue);
      expect(prefs.showEmotionWheel, isFalse);
      expect(prefs.showContextFactors, isFalse);
      expect(prefs.useLegacyMode, isFalse);
      expect(prefs.enabledDimensions, contains('mood'));
      expect(prefs.enabledDimensions, contains('energy'));
      expect(prefs.enabledDimensions.length, 6);
    });

    group('copyWith', () {
      test('updates single field', () {
        const base = RatingPreferences();
        final updated = base.copyWith(useLegacyMode: true);
        expect(updated.useLegacyMode, isTrue);
        expect(updated.mode, RatingMode.balanced); // unchanged
      });

      test('updates multiple fields', () {
        const base = RatingPreferences();
        final updated = base.copyWith(
          mode: RatingMode.detailed,
          showEmotionWheel: true,
          showContextFactors: true,
        );
        expect(updated.mode, RatingMode.detailed);
        expect(updated.showEmotionWheel, isTrue);
        expect(updated.showContextFactors, isTrue);
      });

      test('no-args returns identical values', () {
        const base = RatingPreferences(mode: RatingMode.quick, useLegacyMode: true);
        final copy = base.copyWith();
        expect(copy.mode, RatingMode.quick);
        expect(copy.useLegacyMode, isTrue);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip with all fields', () {
        final prefs = RatingPreferences(
          mode: RatingMode.detailed,
          enabledDimensions: const ['mood', 'energy'],
          showQuickMood: false,
          showEmotionWheel: true,
          showContextFactors: true,
          useLegacyMode: false,
        );
        final restored = RatingPreferences.fromMap(prefs.toMap());
        expect(restored.mode, RatingMode.detailed);
        expect(restored.enabledDimensions, ['mood', 'energy']);
        expect(restored.showQuickMood, isFalse);
        expect(restored.showEmotionWheel, isTrue);
        expect(restored.showContextFactors, isTrue);
        expect(restored.useLegacyMode, isFalse);
      });

      test('missing keys fall back to defaults', () {
        final prefs = RatingPreferences.fromMap({});
        expect(prefs.mode, RatingMode.balanced);
        expect(prefs.showQuickMood, isTrue);
        expect(prefs.useLegacyMode, isFalse);
        expect(prefs.enabledDimensions, isEmpty);
      });

      test('unknown mode falls back to balanced', () {
        final prefs = RatingPreferences.fromMap({'mode': 'unsupported_mode'});
        expect(prefs.mode, RatingMode.balanced);
      });
    });

    group('toJson / fromJson', () {
      test('round-trip', () {
        const prefs = RatingPreferences(
          mode: RatingMode.quick,
          showEmotionWheel: true,
          useLegacyMode: true,
        );
        final restored = RatingPreferences.fromJson(prefs.toJson());
        expect(restored.mode, RatingMode.quick);
        expect(restored.showEmotionWheel, isTrue);
        expect(restored.useLegacyMode, isTrue);
      });
    });

    group('RatingMode enum', () {
      test('all values have distinct names', () {
        final names = RatingMode.values.map((m) => m.name).toList();
        expect(names.toSet().length, RatingMode.values.length);
      });

      test('values are: quick, balanced, detailed, custom', () {
        expect(RatingMode.values.map((m) => m.name),
            containsAll(['quick', 'balanced', 'detailed', 'custom']));
      });
    });
  });
}
