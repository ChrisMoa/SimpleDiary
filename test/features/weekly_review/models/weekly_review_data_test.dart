import 'dart:convert';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyReviewData', () {
    late WeeklyReviewData review;

    setUp(() {
      review = WeeklyReviewData(
        id: 'test-id',
        weekStart: DateTime(2026, 3, 2), // Monday
        weekEnd: DateTime(2026, 3, 8), // Sunday
        year: 2026,
        weekNumber: 10,
        averageScore: 14.5,
        completedDays: 5,
        dailyScoresJson: jsonEncode([
          {'date': '2026-03-02', 'score': 15, 'noteCount': 2, 'isComplete': true, 'categoryScores': {'social': 4}},
        ]),
        categoryAveragesJson: jsonEncode({'social': 3.5, 'productivity': 4.0}),
        permaAveragesJson: jsonEncode({'mood': 3.8, 'energy': 4.2}),
        topEmotionsJson: jsonEncode([
          {'emotion': 'joy', 'count': 3},
          {'emotion': 'gratitude', 'count': 2},
        ]),
        contextSummaryJson: jsonEncode({
          'avgSleep': 7.5,
          'avgSleepQuality': 3.5,
          'exerciseDays': 4,
          'avgStress': 2.1,
        }),
        moodTrendJson: jsonEncode([
          {'date': '2026-03-02', 'valence': 0.5, 'arousal': 0.3},
        ]),
        highlightsJson: jsonEncode({
          'favoriteDays': ['2026-03-04'],
          'favoriteNotes': [{'title': 'Great day', 'category': 'Leisure'}],
        }),
        currentStreak: 12,
        createdAt: DateTime(2026, 3, 9, 20, 0),
      );
    });

    test('construction with all fields', () {
      expect(review.id, 'test-id');
      expect(review.weekStart, DateTime(2026, 3, 2));
      expect(review.weekEnd, DateTime(2026, 3, 8));
      expect(review.year, 2026);
      expect(review.weekNumber, 10);
      expect(review.averageScore, 14.5);
      expect(review.completedDays, 5);
      expect(review.currentStreak, 12);
    });

    test('auto-generates UUID when id not provided', () {
      final r1 = WeeklyReviewData(
        weekStart: DateTime(2026, 3, 2),
        weekEnd: DateTime(2026, 3, 8),
        year: 2026,
        weekNumber: 10,
      );
      final r2 = WeeklyReviewData(
        weekStart: DateTime(2026, 3, 2),
        weekEnd: DateTime(2026, 3, 8),
        year: 2026,
        weekNumber: 10,
      );
      expect(r1.id, isNotEmpty);
      expect(r1.id, isNot(r2.id));
    });

    test('defaults for optional fields', () {
      final r = WeeklyReviewData(
        weekStart: DateTime(2026, 3, 2),
        weekEnd: DateTime(2026, 3, 8),
        year: 2026,
        weekNumber: 10,
      );
      expect(r.averageScore, 0.0);
      expect(r.completedDays, 0);
      expect(r.dailyScoresJson, '[]');
      expect(r.categoryAveragesJson, '{}');
      expect(r.permaAveragesJson, '{}');
      expect(r.topEmotionsJson, '[]');
      expect(r.contextSummaryJson, '{}');
      expect(r.moodTrendJson, '[]');
      expect(r.highlightsJson, '{}');
      expect(r.currentStreak, 0);
    });

    test('primaryKeyValue returns id', () {
      expect(review.primaryKeyValue, 'test-id');
    });

    test('weekLabel returns formatted label', () {
      expect(review.weekLabel, 'Week 10, 2026');
    });

    group('toDbMap/fromDbMap round-trip', () {
      test('preserves all fields', () {
        final map = review.toDbMap();
        final restored = WeeklyReviewData.fromDbMap(map);

        expect(restored.id, review.id);
        expect(restored.weekStart, review.weekStart);
        expect(restored.weekEnd, review.weekEnd);
        expect(restored.year, review.year);
        expect(restored.weekNumber, review.weekNumber);
        expect(restored.averageScore, review.averageScore);
        expect(restored.completedDays, review.completedDays);
        expect(restored.dailyScoresJson, review.dailyScoresJson);
        expect(restored.categoryAveragesJson, review.categoryAveragesJson);
        expect(restored.permaAveragesJson, review.permaAveragesJson);
        expect(restored.topEmotionsJson, review.topEmotionsJson);
        expect(restored.contextSummaryJson, review.contextSummaryJson);
        expect(restored.moodTrendJson, review.moodTrendJson);
        expect(restored.highlightsJson, review.highlightsJson);
        expect(restored.currentStreak, review.currentStreak);
        expect(restored.createdAt, review.createdAt);
      });

      test('handles missing optional fields with defaults', () {
        final map = {
          'id': 'test',
          'weekStart': '2026-03-02T00:00:00.000',
          'weekEnd': '2026-03-08T00:00:00.000',
          'year': 2026,
          'weekNumber': 10,
          'createdAt': '2026-03-09T20:00:00.000',
        };
        final restored = WeeklyReviewData.fromDbMap(map);
        expect(restored.averageScore, 0.0);
        expect(restored.completedDays, 0);
        expect(restored.dailyScoresJson, '[]');
        expect(restored.currentStreak, 0);
      });
    });

    group('typed JSON accessors', () {
      test('dailyScores returns typed list', () {
        final scores = review.dailyScores;
        expect(scores, isList);
        expect(scores.first['score'], 15);
        expect(scores.first['noteCount'], 2);
      });

      test('categoryAverages returns typed map', () {
        final avgs = review.categoryAverages;
        expect(avgs['social'], 3.5);
        expect(avgs['productivity'], 4.0);
      });

      test('permaAverages returns typed map', () {
        final avgs = review.permaAverages;
        expect(avgs['mood'], 3.8);
        expect(avgs['energy'], 4.2);
      });

      test('topEmotions returns typed list', () {
        final emotions = review.topEmotions;
        expect(emotions.length, 2);
        expect(emotions.first['emotion'], 'joy');
        expect(emotions.first['count'], 3);
      });

      test('contextSummary returns typed map', () {
        final ctx = review.contextSummary;
        expect(ctx['avgSleep'], 7.5);
        expect(ctx['exerciseDays'], 4);
      });

      test('moodTrend returns typed list', () {
        final trend = review.moodTrend;
        expect(trend.length, 1);
        expect(trend.first['valence'], 0.5);
      });

      test('highlights returns typed map', () {
        final h = review.highlights;
        expect((h['favoriteDays'] as List).first, '2026-03-04');
        expect((h['favoriteNotes'] as List).first['title'], 'Great day');
      });
    });

    group('copyWith', () {
      test('updates specified fields', () {
        final updated = review.copyWith(
          averageScore: 16.0,
          completedDays: 7,
        );
        expect(updated.averageScore, 16.0);
        expect(updated.completedDays, 7);
        expect(updated.id, review.id); // preserved
        expect(updated.weekNumber, review.weekNumber); // preserved
      });

      test('no-args returns equivalent copy', () {
        final copy = review.copyWith();
        expect(copy.id, review.id);
        expect(copy.averageScore, review.averageScore);
        expect(copy.completedDays, review.completedDays);
      });
    });

    group('isoWeekNumber', () {
      test('calculates correct week for mid-year date', () {
        // March 2, 2026 is a Monday in week 10
        expect(WeeklyReviewData.isoWeekNumber(DateTime(2026, 3, 2)), 10);
      });

      test('calculates week 1 for early January', () {
        // January 5, 2026 is a Monday in week 2
        expect(WeeklyReviewData.isoWeekNumber(DateTime(2026, 1, 5)), 2);
      });

      test('handles year boundary', () {
        // December 29, 2025 is a Monday in week 1 of 2026
        final week = WeeklyReviewData.isoWeekNumber(DateTime(2025, 12, 29));
        expect(week, 1);
      });
    });

    group('mondayOfWeek', () {
      test('returns correct Monday', () {
        final monday = WeeklyReviewData.mondayOfWeek(2026, 10);
        expect(monday.weekday, DateTime.monday);
        expect(monday.year, 2026);
        expect(monday.month, 3);
        expect(monday.day, 2);
      });

      test('returns correct Monday for week 1', () {
        final monday = WeeklyReviewData.mondayOfWeek(2026, 1);
        expect(monday.weekday, DateTime.monday);
        // Week 1 of 2026 starts on Dec 29, 2025
        expect(monday.year, 2025);
        expect(monday.month, 12);
        expect(monday.day, 29);
      });
    });

    group('schema', () {
      test('tableName is weekly_reviews', () {
        expect(WeeklyReviewData.tableName, 'weekly_reviews');
      });

      test('columns contains id as primary key', () {
        final pkColumn = WeeklyReviewData.columns.firstWhere((c) => c.isPrimaryKey);
        expect(pkColumn.name, 'id');
      });

      test('has correct number of columns', () {
        expect(WeeklyReviewData.columns.length, 16);
      });
    });
  });
}
