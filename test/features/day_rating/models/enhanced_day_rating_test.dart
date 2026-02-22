import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ts = DateTime(2024, 6, 15, 20, 30);

  // ── MoodPosition ──────────────────────────────────────────────────────────

  group('MoodPosition', () {
    test('stores valence and arousal', () {
      final mp = MoodPosition(valence: 0.5, arousal: -0.3, timestamp: ts);
      expect(mp.valence, 0.5);
      expect(mp.arousal, -0.3);
      expect(mp.timestamp, ts);
    });

    group('quadrant detection', () {
      test('highEnergyPositive when valence>=0 and arousal>=0', () {
        final mp = MoodPosition(valence: 0.6, arousal: 0.8, timestamp: ts);
        expect(mp.quadrant, MoodQuadrant.highEnergyPositive);
      });

      test('lowEnergyPositive when valence>=0 and arousal<0', () {
        final mp = MoodPosition(valence: 0.4, arousal: -0.5, timestamp: ts);
        expect(mp.quadrant, MoodQuadrant.lowEnergyPositive);
      });

      test('highEnergyNegative when valence<0 and arousal>=0', () {
        final mp = MoodPosition(valence: -0.7, arousal: 0.9, timestamp: ts);
        expect(mp.quadrant, MoodQuadrant.highEnergyNegative);
      });

      test('lowEnergyNegative when valence<0 and arousal<0', () {
        final mp = MoodPosition(valence: -0.4, arousal: -0.6, timestamp: ts);
        expect(mp.quadrant, MoodQuadrant.lowEnergyNegative);
      });
    });

    group('label', () {
      test('Excited for high arousal + high valence', () {
        final mp = MoodPosition(valence: 0.8, arousal: 0.8, timestamp: ts);
        expect(mp.label, 'Excited');
      });

      test('Anxious for high arousal + low valence', () {
        final mp = MoodPosition(valence: -0.8, arousal: 0.8, timestamp: ts);
        expect(mp.label, 'Anxious');
      });

      test('Calm for low arousal + high valence', () {
        final mp = MoodPosition(valence: 0.8, arousal: -0.8, timestamp: ts);
        expect(mp.label, 'Calm');
      });

      test('Sad for low arousal + low valence', () {
        final mp = MoodPosition(valence: -0.8, arousal: -0.8, timestamp: ts);
        expect(mp.label, 'Sad');
      });

      test('Pleasant for moderate positive valence', () {
        final mp = MoodPosition(valence: 0.5, arousal: 0.0, timestamp: ts);
        expect(mp.label, 'Pleasant');
      });

      test('Neutral for near-zero coordinates', () {
        final mp = MoodPosition(valence: 0.1, arousal: 0.1, timestamp: ts);
        expect(mp.label, 'Neutral');
      });
    });

    test('copyWith creates updated copy', () {
      final mp = MoodPosition(valence: 0.5, arousal: 0.5, timestamp: ts);
      final updated = mp.copyWith(valence: -0.5);
      expect(updated.valence, -0.5);
      expect(updated.arousal, 0.5);
    });

    test('toMap / fromMap round-trip', () {
      final mp = MoodPosition(valence: 0.3, arousal: -0.7, timestamp: ts);
      final map = mp.toMap();
      final restored = MoodPosition.fromMap(map);
      expect(restored.valence, closeTo(0.3, 0.001));
      expect(restored.arousal, closeTo(-0.7, 0.001));
      expect(restored.timestamp, ts);
    });
  });

  // ── WellbeingRating ───────────────────────────────────────────────────────

  group('WellbeingRating', () {
    test('defaults are all zero', () {
      const wr = WellbeingRating();
      expect(wr.mood, 0);
      expect(wr.energy, 0);
      expect(wr.connection, 0);
      expect(wr.purpose, 0);
      expect(wr.achievement, 0);
      expect(wr.engagement, 0);
    });

    test('totalScore sums all fields', () {
      const wr = WellbeingRating(
          mood: 4, energy: 3, connection: 5, purpose: 2, achievement: 4, engagement: 3);
      expect(wr.totalScore, 21);
    });

    test('averageScore excludes zeros', () {
      const wr = WellbeingRating(mood: 4, energy: 2);
      expect(wr.averageScore, closeTo(3.0, 0.01));
    });

    test('averageScore is 0.0 when nothing rated', () {
      expect(const WellbeingRating().averageScore, 0.0);
    });

    test('isComplete requires mood and energy > 0', () {
      expect(const WellbeingRating(mood: 3, energy: 2).isComplete, isTrue);
      expect(const WellbeingRating(mood: 3).isComplete, isFalse);
      expect(const WellbeingRating(energy: 2).isComplete, isFalse);
    });

    test('copyWith updates individual fields', () {
      const base = WellbeingRating(mood: 3, energy: 3);
      final updated = base.copyWith(mood: 5, connection: 4);
      expect(updated.mood, 5);
      expect(updated.energy, 3);
      expect(updated.connection, 4);
    });

    test('toMap / fromMap round-trip', () {
      const wr = WellbeingRating(
          mood: 4, energy: 5, connection: 3, purpose: 2, achievement: 4, engagement: 3);
      final restored = WellbeingRating.fromMap(wr.toMap());
      expect(restored.mood, 4);
      expect(restored.energy, 5);
      expect(restored.connection, 3);
      expect(restored.purpose, 2);
      expect(restored.achievement, 4);
      expect(restored.engagement, 3);
    });

    test('fromMap with missing keys defaults to zero', () {
      final wr = WellbeingRating.fromMap({});
      expect(wr.mood, 0);
      expect(wr.totalScore, 0);
    });

    test('WellbeingRating.empty() is all zeros', () {
      final wr = WellbeingRating.empty();
      expect(wr.totalScore, 0);
      expect(wr.averageScore, 0.0);
    });
  });

  // ── EmotionEntry ──────────────────────────────────────────────────────────

  group('EmotionEntry', () {
    test('stores emotion and intensity', () {
      const e = EmotionEntry(emotion: EmotionType.joy, intensity: 2);
      expect(e.emotion, EmotionType.joy);
      expect(e.intensity, 2);
    });

    test('copyWith updates fields', () {
      const e = EmotionEntry(emotion: EmotionType.joy, intensity: 1);
      final updated = e.copyWith(intensity: 3);
      expect(updated.emotion, EmotionType.joy);
      expect(updated.intensity, 3);
    });

    test('toMap / fromMap round-trip', () {
      const e = EmotionEntry(emotion: EmotionType.anxiety, intensity: 3);
      final restored = EmotionEntry.fromMap(e.toMap());
      expect(restored.emotion, EmotionType.anxiety);
      expect(restored.intensity, 3);
    });

    test('fromMap unknown emotion falls back to neutral', () {
      final e = EmotionEntry.fromMap({'emotion': 'unknown_xyz', 'intensity': 1});
      expect(e.emotion, EmotionType.neutral);
    });
  });

  // ── ContextualFactors ─────────────────────────────────────────────────────

  group('ContextualFactors', () {
    test('defaults are all null / empty', () {
      const cf = ContextualFactors();
      expect(cf.sleepHours, isNull);
      expect(cf.sleepQuality, isNull);
      expect(cf.exercised, isNull);
      expect(cf.stressLevel, isNull);
      expect(cf.tags, isEmpty);
    });

    test('copyWith updates individual fields', () {
      const base = ContextualFactors(sleepHours: 7.0);
      final updated = base.copyWith(exercised: true, stressLevel: 3);
      expect(updated.sleepHours, 7.0);
      expect(updated.exercised, true);
      expect(updated.stressLevel, 3);
    });

    test('toMap / fromMap round-trip', () {
      final cf = ContextualFactors(
        sleepHours: 6.5,
        sleepQuality: 4,
        exercised: true,
        stressLevel: 2,
        tags: ['travel', 'tired'],
      );
      final restored = ContextualFactors.fromMap(cf.toMap());
      expect(restored.sleepHours, 6.5);
      expect(restored.sleepQuality, 4);
      expect(restored.exercised, true);
      expect(restored.stressLevel, 2);
      expect(restored.tags, ['travel', 'tired']);
    });

    test('fromMap with missing keys gives null / empty', () {
      final cf = ContextualFactors.fromMap({});
      expect(cf.sleepHours, isNull);
      expect(cf.tags, isEmpty);
    });

    test('ContextualFactors.empty() has no data', () {
      final cf = ContextualFactors.empty();
      expect(cf.sleepHours, isNull);
      expect(cf.tags, isEmpty);
    });
  });

  // ── EnhancedDayRating ─────────────────────────────────────────────────────

  group('EnhancedDayRating', () {
    final date = DateTime(2024, 6, 15);

    test('empty factory sets date, empty wellbeing', () {
      final edr = EnhancedDayRating.empty(date);
      expect(edr.date, date);
      expect(edr.quickMood, isNull);
      expect(edr.wellbeing.totalScore, 0);
      expect(edr.emotions, isEmpty);
    });

    test('overallScore is 0 when nothing rated', () {
      final edr = EnhancedDayRating.empty(date);
      expect(edr.overallScore, 0);
    });

    test('overallScore scales wellbeing total to 0-20', () {
      // Max wellbeing = 30 → overallScore should be 20
      final edr = EnhancedDayRating(
        date: date,
        wellbeing: const WellbeingRating(
            mood: 5, energy: 5, connection: 5, purpose: 5, achievement: 5, engagement: 5),
      );
      expect(edr.overallScore, 20);
    });

    test('overallScore at half wellbeing ≈ 10', () {
      final edr = EnhancedDayRating(
        date: date,
        wellbeing: const WellbeingRating(
            mood: 3, energy: 3, connection: 3, purpose: 3, achievement: 3, engagement: 3),
      );
      expect(edr.overallScore, 12); // (18/30)*20 = 12
    });

    test('copyWith updates fields', () {
      final base = EnhancedDayRating.empty(date);
      const newWellbeing = WellbeingRating(mood: 4, energy: 4);
      final updated = base.copyWith(wellbeing: newWellbeing);
      expect(updated.wellbeing.mood, 4);
      expect(updated.date, date);
    });

    test('toMap / fromMap round-trip without quickMood', () {
      final edr = EnhancedDayRating(
        date: date,
        wellbeing: const WellbeingRating(mood: 3, energy: 4),
        emotions: [
          const EmotionEntry(emotion: EmotionType.joy, intensity: 2),
        ],
        context: ContextualFactors(
          sleepHours: 7.0,
          exercised: true,
          tags: ['gym'],
        ),
      );
      final map = edr.toMap();
      final restored = EnhancedDayRating.fromMap(map);
      expect(restored.date, date);
      expect(restored.quickMood, isNull);
      expect(restored.wellbeing.mood, 3);
      expect(restored.wellbeing.energy, 4);
      expect(restored.emotions.length, 1);
      expect(restored.emotions.first.emotion, EmotionType.joy);
      expect(restored.context.sleepHours, 7.0);
      expect(restored.context.tags, ['gym']);
    });

    test('toMap / fromMap round-trip with quickMood', () {
      final edr = EnhancedDayRating(
        date: date,
        quickMood: MoodPosition(valence: 0.5, arousal: -0.3, timestamp: ts),
        wellbeing: const WellbeingRating(mood: 5),
      );
      final restored = EnhancedDayRating.fromMap(edr.toMap());
      expect(restored.quickMood, isNotNull);
      expect(restored.quickMood!.valence, closeTo(0.5, 0.001));
      expect(restored.quickMood!.arousal, closeTo(-0.3, 0.001));
    });

    test('toJson / fromJson round-trip', () {
      final edr = EnhancedDayRating(
        date: date,
        wellbeing: const WellbeingRating(mood: 4, energy: 3, connection: 5),
      );
      final json = edr.toJson();
      final restored = EnhancedDayRating.fromJson(json);
      expect(restored.wellbeing.mood, 4);
      expect(restored.wellbeing.connection, 5);
    });
  });
}
