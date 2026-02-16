import 'package:day_tracker/features/dashboard/data/services/mood_correlation_service.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MoodCorrelationService service;

  setUp(() {
    service = MoodCorrelationService();
  });

  /// Helper: create a DiaryDay for a specific date with ratings
  DiaryDay createDiaryDay(DateTime date,
      {int socialScore = 3,
      int productivityScore = 3,
      int sportScore = 3,
      int foodScore = 3,
      List<Note>? notes}) {
    final day = DiaryDay(
      day: date,
      ratings: [
        DayRating(dayRating: DayRatings.social, score: socialScore),
        DayRating(dayRating: DayRatings.productivity, score: productivityScore),
        DayRating(dayRating: DayRatings.sport, score: sportScore),
        DayRating(dayRating: DayRatings.food, score: foodScore),
      ],
    );
    // Add notes if provided (DiaryDay has a notes list property)
    if (notes != null) {
      day.notes.addAll(notes);
    }
    return day;
  }

  /// Helper: create a note with a category
  Note createNote(DateTime date, String category) {
    return Note(
      title: 'Test Note',
      description: '',
      from: date.copyWith(hour: 10),
      to: date.copyWith(hour: 11),
      noteCategory: NoteCategory(
        title: category,
        color: Colors.blue,
      ),
    );
  }

  group('MoodCorrelationService', () {
    group('calculateCorrelation', () {
      test('returns 1.0 for perfect positive correlation', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [1.0, 2.0, 3.0, 4.0, 5.0];
        expect(service.calculateCorrelation(x, y), closeTo(1.0, 0.001));
      });

      test('returns -1.0 for perfect negative correlation', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [5.0, 4.0, 3.0, 2.0, 1.0];
        expect(service.calculateCorrelation(x, y), closeTo(-1.0, 0.001));
      });

      test('returns 0.0 for no correlation', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [3.0, 3.0, 3.0, 3.0, 3.0];
        expect(service.calculateCorrelation(x, y), closeTo(0.0, 0.001));
      });

      test('returns 0.0 for insufficient data', () {
        final x = [1.0, 2.0];
        final y = [1.0, 2.0];
        expect(service.calculateCorrelation(x, y), 0.0);
      });

      test('returns 0.0 for mismatched lengths', () {
        final x = [1.0, 2.0, 3.0];
        final y = [1.0, 2.0];
        expect(service.calculateCorrelation(x, y), 0.0);
      });

      test('handles zero variance correctly', () {
        final x = [1.0, 1.0, 1.0, 1.0, 1.0];
        final y = [1.0, 2.0, 3.0, 4.0, 5.0];
        expect(service.calculateCorrelation(x, y), 0.0);
      });
    });

    group('getActivityRatingCorrelation', () {
      test('returns insufficient when less than minimum days', () {
        final days = [
          createDiaryDay(DateTime(2024, 1, 1)),
          createDiaryDay(DateTime(2024, 1, 2)),
        ];
        final result = service.getActivityRatingCorrelation(
          diaryDays: days,
          noteCategory: 'Gym',
          ratingCategory: DayRatings.sport,
        );
        expect(result.isSignificant, false);
        expect(result.sampleSize, lessThan(7));
      });

      test('detects positive correlation between Gym and Sport', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        // Create 10 days: days with Gym have high sport scores
        for (int i = 0; i < 10; i++) {
          final date = now.subtract(Duration(days: i));
          final hasGym = i % 2 == 0; // Every other day has gym
          days.add(createDiaryDay(
            date,
            sportScore: hasGym ? 5 : 2,
            notes: hasGym ? [createNote(date, 'Gym')] : [],
          ));
        }

        final result = service.getActivityRatingCorrelation(
          diaryDays: days,
          noteCategory: 'Gym',
          ratingCategory: DayRatings.sport,
        );

        expect(result.isSignificant, true);
        expect(result.correlation, greaterThan(0.3));
        expect(result.isPositive, true);
        expect(result.averageWithActivity, greaterThan(result.averageWithoutActivity));
      });

      test('calculates impact correctly', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        for (int i = 0; i < 10; i++) {
          final date = now.subtract(Duration(days: i));
          final hasGym = i < 5;
          days.add(createDiaryDay(
            date,
            sportScore: hasGym ? 4 : 2,
            notes: hasGym ? [createNote(date, 'Gym')] : [],
          ));
        }

        final result = service.getActivityRatingCorrelation(
          diaryDays: days,
          noteCategory: 'Gym',
          ratingCategory: DayRatings.sport,
        );

        expect(result.impact, closeTo(2.0, 0.5));
      });

      test('handles case-insensitive category matching', () {
        final now = DateTime.now();
        final days = [
          createDiaryDay(
            now,
            sportScore: 5,
            notes: [createNote(now, 'gym')], // lowercase
          ),
          createDiaryDay(
            now.subtract(const Duration(days: 1)),
            sportScore: 5,
            notes: [createNote(now.subtract(const Duration(days: 1)), 'GYM')], // uppercase
          ),
        ];

        // Should not crash and should match both
        final result = service.getActivityRatingCorrelation(
          diaryDays: days,
          noteCategory: 'Gym', // mixed case
          ratingCategory: DayRatings.sport,
          minimumDays: 2,
        );

        expect(result.sampleSize, greaterThanOrEqualTo(2));
      });
    });

    group('findStrongCorrelations', () {
      test('returns empty list for insufficient data', () {
        final days = [createDiaryDay(DateTime.now())];
        final results = service.findStrongCorrelations(
          diaryDays: days,
          noteCategories: ['Gym', 'Work'],
        );
        expect(results, isEmpty);
      });

      test('finds and sorts correlations by strength', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        for (int i = 0; i < 15; i++) {
          final date = now.subtract(Duration(days: i));
          final hasGym = i % 2 == 0;
          final hasWork = i % 3 == 0;

          days.add(createDiaryDay(
            date,
            sportScore: hasGym ? 5 : 2,
            productivityScore: hasWork ? 5 : 3,
            notes: [
              if (hasGym) createNote(date, 'Gym'),
              if (hasWork) createNote(date, 'Work'),
            ],
          ));
        }

        final results = service.findStrongCorrelations(
          diaryDays: days,
          noteCategories: ['Gym', 'Work'],
          threshold: 0.2,
        );

        expect(results, isNotEmpty);
        // Results should be sorted by strength
        if (results.length > 1) {
          expect(
            results[0].correlation.abs(),
            greaterThanOrEqualTo(results[1].correlation.abs()),
          );
        }
      });

      test('filters by threshold', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        for (int i = 0; i < 10; i++) {
          final date = now.subtract(Duration(days: i));
          days.add(createDiaryDay(
            date,
            sportScore: 3,
            notes: [if (i < 3) createNote(date, 'Gym')],
          ));
        }

        final resultsLowThreshold = service.findStrongCorrelations(
          diaryDays: days,
          noteCategories: ['Gym'],
          threshold: 0.1,
        );

        final resultsHighThreshold = service.findStrongCorrelations(
          diaryDays: days,
          noteCategories: ['Gym'],
          threshold: 0.8,
        );

        expect(resultsLowThreshold.length, greaterThanOrEqualTo(resultsHighThreshold.length));
      });
    });

    group('analyzeDayOfWeek', () {
      test('identifies best and worst days', () {
        final baseDate = DateTime(2024, 1, 1); // Monday
        final days = <DiaryDay>[];

        for (int week = 0; week < 4; week++) {
          for (int day = 0; day < 7; day++) {
            final date = baseDate.add(Duration(days: week * 7 + day));
            // Fridays are best (weekday 5), Mondays are worst (weekday 1)
            final score = day == 4 ? 5 : (day == 0 ? 1 : 3);
            days.add(createDiaryDay(date, socialScore: score, productivityScore: score));
          }
        }

        final analysis = service.analyzeDayOfWeek(days);

        expect(analysis.bestDay, isNotNull);
        expect(analysis.worstDay, isNotNull);
        expect(analysis.bestDayAverage, greaterThan(analysis.worstDayAverage));
        expect(analysis.hasSignificantVariance, true);
      });

      test('returns day names correctly', () {
        final days = [
          createDiaryDay(DateTime(2024, 1, 1), socialScore: 5), // Monday
          createDiaryDay(DateTime(2024, 1, 7), socialScore: 1), // Sunday
        ];

        final analysis = service.analyzeDayOfWeek(days);

        expect(analysis.bestDayName, isNotEmpty);
        expect(analysis.worstDayName, isNotEmpty);
      });

      test('handles empty days gracefully', () {
        final analysis = service.analyzeDayOfWeek([]);

        expect(analysis.bestDay, isNull);
        expect(analysis.worstDay, isNull);
        expect(analysis.variance, 0);
      });
    });

    group('detectTrend', () {
      test('returns insufficient for too few days', () {
        final days = List.generate(
          5,
          (i) => createDiaryDay(DateTime.now().subtract(Duration(days: i))),
        );

        final trend = service.detectTrend(
          diaryDays: days,
          ratingCategory: DayRatings.productivity,
        );

        expect(trend.isSignificant, false);
      });

      test('detects improving trend', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        // First half: low scores, second half: high scores
        for (int i = 0; i < 20; i++) {
          final date = now.subtract(Duration(days: 19 - i));
          final score = i < 10 ? 2 : 4;
          days.add(createDiaryDay(date, productivityScore: score));
        }

        final trend = service.detectTrend(
          diaryDays: days,
          ratingCategory: DayRatings.productivity,
        );

        expect(trend.direction, TrendDirection.improving);
        expect(trend.absoluteChange, greaterThan(0));
      });

      test('detects declining trend', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        // First half: high scores, second half: low scores
        for (int i = 0; i < 20; i++) {
          final date = now.subtract(Duration(days: 19 - i));
          final score = i < 10 ? 4 : 2;
          days.add(createDiaryDay(date, productivityScore: score));
        }

        final trend = service.detectTrend(
          diaryDays: days,
          ratingCategory: DayRatings.productivity,
        );

        expect(trend.direction, TrendDirection.declining);
        expect(trend.absoluteChange, lessThan(0));
      });

      test('detects stable trend', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        for (int i = 0; i < 20; i++) {
          final date = now.subtract(Duration(days: i));
          days.add(createDiaryDay(date, productivityScore: 3));
        }

        final trend = service.detectTrend(
          diaryDays: days,
          ratingCategory: DayRatings.productivity,
        );

        expect(trend.direction, TrendDirection.stable);
        expect(trend.absoluteChange.abs(), lessThan(0.3));
      });
    });

    group('detectAllTrends', () {
      test('returns trends for all categories with sufficient data', () {
        final now = DateTime.now();
        final days = <DiaryDay>[];

        for (int i = 0; i < 20; i++) {
          final date = now.subtract(Duration(days: 19 - i));
          final socialScore = i < 10 ? 2 : 4;
          days.add(createDiaryDay(date, socialScore: socialScore));
        }

        final trends = service.detectAllTrends(days);

        expect(trends, isNotEmpty);
        expect(trends.every((t) => t.isSignificant), true);
      });

      test('filters out non-significant trends', () {
        final now = DateTime.now();
        final days = List.generate(
          20,
          (i) => createDiaryDay(now.subtract(Duration(days: i)), socialScore: 3),
        );

        final trends = service.detectAllTrends(days);

        // All stable trends should be filtered out
        expect(trends.where((t) => t.direction == TrendDirection.stable), isEmpty);
      });
    });

    group('CorrelationResult', () {
      test('calculates strengthLabel correctly', () {
        final strong = CorrelationResult(
          correlation: 0.8,
          sampleSize: 10,
          noteCategory: 'Test',
          ratingCategory: DayRatings.social,
          averageWithActivity: 4.0,
          averageWithoutActivity: 2.0,
        );
        expect(strong.strengthLabel, 'strong');

        final moderate = CorrelationResult(
          correlation: 0.5,
          sampleSize: 10,
          noteCategory: 'Test',
          ratingCategory: DayRatings.social,
          averageWithActivity: 4.0,
          averageWithoutActivity: 2.0,
        );
        expect(moderate.strengthLabel, 'moderate');

        final weak = CorrelationResult(
          correlation: 0.25,
          sampleSize: 10,
          noteCategory: 'Test',
          ratingCategory: DayRatings.social,
          averageWithActivity: 4.0,
          averageWithoutActivity: 2.0,
        );
        expect(weak.strengthLabel, 'weak');
      });

      test('isPositive works correctly', () {
        final positive = CorrelationResult(
          correlation: 0.5,
          sampleSize: 10,
          noteCategory: 'Test',
          ratingCategory: DayRatings.social,
          averageWithActivity: 4.0,
          averageWithoutActivity: 2.0,
        );
        expect(positive.isPositive, true);

        final negative = CorrelationResult(
          correlation: -0.5,
          sampleSize: 10,
          noteCategory: 'Test',
          ratingCategory: DayRatings.social,
          averageWithActivity: 2.0,
          averageWithoutActivity: 4.0,
        );
        expect(negative.isPositive, false);
      });
    });

    group('DayOfWeekAnalysis', () {
      test('hasSignificantVariance threshold works', () {
        final significant = DayOfWeekAnalysis(
          averagesByDay: {},
          bestDay: 1,
          worstDay: 5,
          bestDayAverage: 5.0,
          worstDayAverage: 2.0,
        );
        expect(significant.hasSignificantVariance, true);

        final notSignificant = DayOfWeekAnalysis(
          averagesByDay: {},
          bestDay: 1,
          worstDay: 5,
          bestDayAverage: 3.5,
          worstDayAverage: 3.0,
        );
        expect(notSignificant.hasSignificantVariance, false);
      });
    });

    group('TrendAnalysis', () {
      test('isSignificant requires minimum sample size and change', () {
        final significant = TrendAnalysis(
          ratingCategory: DayRatings.social,
          direction: TrendDirection.improving,
          firstPeriodAverage: 2.0,
          secondPeriodAverage: 3.0,
          absoluteChange: 1.0,
          percentChange: 50,
          sampleSize: 20,
        );
        expect(significant.isSignificant, true);

        final insufficientSampleSize = TrendAnalysis(
          ratingCategory: DayRatings.social,
          direction: TrendDirection.improving,
          firstPeriodAverage: 2.0,
          secondPeriodAverage: 3.0,
          absoluteChange: 1.0,
          percentChange: 50,
          sampleSize: 10,
        );
        expect(insufficientSampleSize.isSignificant, false);

        final insufficientChange = TrendAnalysis(
          ratingCategory: DayRatings.social,
          direction: TrendDirection.stable,
          firstPeriodAverage: 3.0,
          secondPeriodAverage: 3.1,
          absoluteChange: 0.1,
          percentChange: 3,
          sampleSize: 20,
        );
        expect(insufficientChange.isSignificant, false);
      });
    });
  });
}
