import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/streak_data.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakData', () {
    test('empty factory creates zeroed streak', () {
      final streak = StreakData.empty();
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isActive, false);
      expect(streak.lastEntryDate, isNull);
      expect(streak.streakDates, isEmpty);
    });

    group('isMilestone', () {
      test('7-day streak is a milestone', () {
        final streak = StreakData(
          currentStreak: 7,
          longestStreak: 7,
          streakDates: [],
          isActive: true,
        );
        expect(streak.isMilestone, true);
      });

      test('30-day streak is a milestone', () {
        final streak = StreakData(
          currentStreak: 30,
          longestStreak: 30,
          streakDates: [],
          isActive: true,
        );
        expect(streak.isMilestone, true);
      });

      test('100-day streak is a milestone', () {
        final streak = StreakData(
          currentStreak: 100,
          longestStreak: 100,
          streakDates: [],
          isActive: true,
        );
        expect(streak.isMilestone, true);
      });

      test('365-day streak is a milestone', () {
        final streak = StreakData(
          currentStreak: 365,
          longestStreak: 365,
          streakDates: [],
          isActive: true,
        );
        expect(streak.isMilestone, true);
      });

      test('non-milestone counts return false', () {
        for (final count in [1, 5, 10, 15, 29, 50, 99, 200, 364]) {
          final streak = StreakData(
            currentStreak: count,
            longestStreak: count,
            streakDates: [],
            isActive: true,
          );
          expect(streak.isMilestone, false, reason: '$count should not be a milestone');
        }
      });
    });

    group('milestoneText', () {
      test('365+ returns 1 Jahr text', () {
        final streak = StreakData(
          currentStreak: 365,
          longestStreak: 365,
          streakDates: [],
          isActive: true,
        );
        expect(streak.milestoneText, contains('Jahr'));
      });

      test('100+ returns 100 Tage text', () {
        final streak = StreakData(
          currentStreak: 100,
          longestStreak: 100,
          streakDates: [],
          isActive: true,
        );
        expect(streak.milestoneText, contains('100'));
      });

      test('30+ returns 30 Tage text', () {
        final streak = StreakData(
          currentStreak: 30,
          longestStreak: 30,
          streakDates: [],
          isActive: true,
        );
        expect(streak.milestoneText, contains('30'));
      });

      test('7+ returns 1 Woche text', () {
        final streak = StreakData(
          currentStreak: 7,
          longestStreak: 7,
          streakDates: [],
          isActive: true,
        );
        expect(streak.milestoneText, contains('Woche'));
      });

      test('below 7 returns empty string', () {
        final streak = StreakData(
          currentStreak: 3,
          longestStreak: 3,
          streakDates: [],
          isActive: true,
        );
        expect(streak.milestoneText, '');
      });
    });

    test('copyWith preserves unchanged fields', () {
      final original = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastEntryDate: DateTime(2024, 3, 15),
        streakDates: [DateTime(2024, 3, 15)],
        isActive: true,
      );
      final copy = original.copyWith(currentStreak: 6);
      expect(copy.currentStreak, 6);
      expect(copy.longestStreak, 10);
      expect(copy.isActive, true);
    });
  });

  group('WeekStats', () {
    test('creates with all fields', () {
      final stats = WeekStats(
        averageScore: 15.5,
        completedDays: 5,
        categoryAverages: {'social': 4.0, 'sport': 3.5},
        dailyScores: [],
      );
      expect(stats.averageScore, 15.5);
      expect(stats.completedDays, 5);
      expect(stats.categoryAverages.length, 2);
    });

    test('copyWith preserves unchanged fields', () {
      final original = WeekStats(
        averageScore: 12.0,
        completedDays: 3,
        categoryAverages: {'social': 4.0},
        dailyScores: [],
      );
      final copy = original.copyWith(completedDays: 5);
      expect(copy.completedDays, 5);
      expect(copy.averageScore, 12.0);
    });
  });

  group('DayScore', () {
    test('creates with all fields', () {
      final score = DayScore(
        date: DateTime(2024, 3, 15),
        totalScore: 16,
        categoryScores: {'social': 4, 'sport': 5},
        noteCount: 3,
        isComplete: true,
      );
      expect(score.totalScore, 16);
      expect(score.noteCount, 3);
      expect(score.isComplete, true);
    });

    test('copyWith preserves unchanged fields', () {
      final original = DayScore(
        date: DateTime(2024, 3, 15),
        totalScore: 16,
        categoryScores: {},
        noteCount: 3,
        isComplete: true,
      );
      final copy = original.copyWith(noteCount: 5);
      expect(copy.noteCount, 5);
      expect(copy.totalScore, 16);
      expect(copy.isComplete, true);
    });
  });

  group('Insight', () {
    test('creates with all fields', () {
      final insight = Insight(
        title: 'Test Insight',
        description: 'A description',
        type: InsightType.achievement,
        icon: '⭐',
      );
      expect(insight.title, 'Test Insight');
      expect(insight.type, InsightType.achievement);
      expect(insight.createdAt, isNotNull);
      expect(insight.metadata, isNull);
    });

    test('creates with metadata', () {
      final insight = Insight(
        title: 'Test',
        description: 'Desc',
        type: InsightType.milestone,
        icon: '🎉',
        metadata: {'streak': 30},
      );
      expect(insight.metadata, isNotNull);
      expect(insight.metadata!['streak'], 30);
    });

    test('copyWith preserves unchanged fields', () {
      final original = Insight(
        title: 'Original',
        description: 'Desc',
        type: InsightType.suggestion,
        icon: '💡',
      );
      final copy = original.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.description, 'Desc');
      expect(copy.type, InsightType.suggestion);
      expect(copy.icon, '💡');
    });

    test('InsightType enum has all expected values', () {
      expect(InsightType.values, contains(InsightType.achievement));
      expect(InsightType.values, contains(InsightType.improvement));
      expect(InsightType.values, contains(InsightType.warning));
      expect(InsightType.values, contains(InsightType.suggestion));
      expect(InsightType.values, contains(InsightType.milestone));
      expect(InsightType.values.length, 5);
    });
  });

  group('DashboardStats', () {
    test('creates with all fields', () {
      final stats = DashboardStats(
        currentStreak: 5,
        todayLogged: true,
        weekStats: WeekStats(
          averageScore: 12.0,
          completedDays: 3,
          categoryAverages: {},
          dailyScores: [],
        ),
        monthlyTrend: {'Woche 1': 14.0},
        topActivities: ['Arbeit', 'Gym'],
        insights: [],
      );
      expect(stats.currentStreak, 5);
      expect(stats.todayLogged, true);
      expect(stats.lastUpdated, isNotNull);
    });

    test('copyWith preserves unchanged fields', () {
      final original = DashboardStats(
        currentStreak: 5,
        todayLogged: true,
        weekStats: WeekStats(
          averageScore: 12.0,
          completedDays: 3,
          categoryAverages: {},
          dailyScores: [],
        ),
        monthlyTrend: {},
        topActivities: [],
        insights: [],
      );
      final copy = original.copyWith(currentStreak: 10);
      expect(copy.currentStreak, 10);
      expect(copy.todayLogged, true);
      expect(copy.weekStats.averageScore, 12.0);
    });
  });
}
