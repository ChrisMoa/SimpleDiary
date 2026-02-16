import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/repositories/goal_repository.dart';

void main() {
  group('GoalRepository', () {
    late GoalRepository repository;

    setUp(() {
      repository = GoalRepository();
    });

    List<DiaryDay> createMockDaysWithRatings(
      DayRatings category,
      List<int> scores,
      DateTime startDate,
    ) {
      return List.generate(scores.length, (index) {
        final day = startDate.add(Duration(days: index));
        return DiaryDay(
          day: day,
          ratings: [
            DayRating(dayRating: category, score: scores[index]),
          ],
        );
      });
    }

    group('calculateProgress', () {
      test('returns correct average for days in goal period', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 4.0,
          startDate: DateTime(2026, 2, 10),
        );
        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [3, 4, 5, 4, 3],
          DateTime(2026, 2, 10),
        );

        final progress = repository.calculateProgress(
          goal: goal,
          diaryDays: diaryDays,
          previousPeriodDays: [],
        );

        expect(progress.currentAverage, closeTo(3.8, 0.01));
        expect(progress.entriesCount, 5);
      });

      test('ignores days outside goal period', () {
        final goal = Goal.weekly(
          category: DayRatings.sport,
          targetValue: 4.0,
          startDate: DateTime(2026, 2, 10),
        );

        // Days both inside and outside the goal period
        final diaryDays = [
          ...createMockDaysWithRatings(
            DayRatings.sport,
            [5, 5], // Before period
            DateTime(2026, 2, 8),
          ),
          ...createMockDaysWithRatings(
            DayRatings.sport,
            [3, 4, 4], // Inside period
            DateTime(2026, 2, 10),
          ),
          ...createMockDaysWithRatings(
            DayRatings.sport,
            [5], // After period
            DateTime(2026, 2, 17),
          ),
        ];

        final progress = repository.calculateProgress(
          goal: goal,
          diaryDays: diaryDays,
          previousPeriodDays: [],
        );

        // Should only include the 3 days inside the period
        expect(progress.entriesCount, 3);
        expect(progress.currentAverage, closeTo(3.67, 0.01));
      });

      test('calculates previous period average correctly', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 4.0,
          startDate: DateTime(2026, 2, 10),
        );

        final currentDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [4, 4, 5],
          DateTime(2026, 2, 10),
        );

        final previousDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [3, 3, 3],
          DateTime(2026, 2, 3),
        );

        final progress = repository.calculateProgress(
          goal: goal,
          diaryDays: currentDays,
          previousPeriodDays: previousDays,
        );

        expect(progress.previousPeriodAverage, closeTo(3.0, 0.01));
      });

      test('handles empty diary days', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 4.0,
          startDate: DateTime(2026, 2, 10),
        );

        final progress = repository.calculateProgress(
          goal: goal,
          diaryDays: [],
          previousPeriodDays: [],
        );

        expect(progress.currentAverage, 0.0);
        expect(progress.entriesCount, 0);
      });
    });

    group('suggestTarget', () {
      test('suggests 15% improvement over current average', () {
        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [3, 3, 4, 3, 3],
          DateTime(2026, 1, 1),
        );

        final suggestion = repository.suggestTarget(
          category: DayRatings.productivity,
          diaryDays: diaryDays,
        );

        // Average is 3.2, so 15% improvement = 3.68
        expect(suggestion, closeTo(3.68, 0.01));
      });

      test('clamps suggestion to maximum 5.0', () {
        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [5, 5, 5, 5, 5],
          DateTime(2026, 1, 1),
        );

        final suggestion = repository.suggestTarget(
          category: DayRatings.productivity,
          diaryDays: diaryDays,
        );

        expect(suggestion, 5.0);
      });

      test('returns default 3.0 for empty diary days', () {
        final suggestion = repository.suggestTarget(
          category: DayRatings.productivity,
          diaryDays: [],
        );

        expect(suggestion, 3.0);
      });

      test('allows custom improvement factor', () {
        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [4, 4, 4],
          DateTime(2026, 1, 1),
        );

        final suggestion = repository.suggestTarget(
          category: DayRatings.productivity,
          diaryDays: diaryDays,
          improvementFactor: 0.25, // 25% improvement
        );

        // Average is 4.0, so 25% improvement = 5.0
        expect(suggestion, 5.0);
      });
    });

    group('checkGoalCompletions', () {
      test('marks achieved goals as completed', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 3.5,
          startDate: DateTime(2026, 2, 1),
        );

        // Goal ended 5 days ago
        final endedGoal = Goal(
          id: goal.id,
          category: goal.category,
          targetValue: goal.targetValue,
          timeframe: goal.timeframe,
          startDate: goal.startDate,
          endDate: DateTime.now().subtract(const Duration(days: 5)),
          status: GoalStatus.active,
          createdAt: goal.createdAt,
        );

        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [4, 4, 4, 4, 4],
          goal.startDate,
        );

        final updated = repository.checkGoalCompletions(
          goals: [endedGoal],
          diaryDays: diaryDays,
        );

        expect(updated.length, 1);
        expect(updated.first.status, GoalStatus.completed);
        expect(updated.first.completedAt, isNotNull);
      });

      test('marks unachieved goals as failed', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 5.0,
          startDate: DateTime(2026, 2, 1),
        );

        // Goal ended 5 days ago
        final endedGoal = Goal(
          id: goal.id,
          category: goal.category,
          targetValue: goal.targetValue,
          timeframe: goal.timeframe,
          startDate: goal.startDate,
          endDate: DateTime.now().subtract(const Duration(days: 5)),
          status: GoalStatus.active,
          createdAt: goal.createdAt,
        );

        final diaryDays = createMockDaysWithRatings(
          DayRatings.productivity,
          [2, 2, 2, 2, 2],
          goal.startDate,
        );

        final updated = repository.checkGoalCompletions(
          goals: [endedGoal],
          diaryDays: diaryDays,
        );

        expect(updated.length, 1);
        expect(updated.first.status, GoalStatus.failed);
      });

      test('does not update goals that have not ended', () {
        final goal = Goal.weekly(
          category: DayRatings.productivity,
          targetValue: 4.0,
          startDate: DateTime.now().subtract(const Duration(days: 3)),
        );

        final updated = repository.checkGoalCompletions(
          goals: [goal],
          diaryDays: [],
        );

        expect(updated, isEmpty);
      });
    });

    group('calculateGoalStreak', () {
      test('counts consecutive completed goals', () {
        final goals = [
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 7),
            status: GoalStatus.completed,
            completedAt: DateTime(2026, 2, 7),
          ),
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 8),
            endDate: DateTime(2026, 2, 14),
            status: GoalStatus.completed,
            completedAt: DateTime(2026, 2, 14),
          ),
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 15),
            endDate: DateTime(2026, 2, 21),
            status: GoalStatus.completed,
            completedAt: DateTime(2026, 2, 21),
          ),
        ];

        expect(repository.calculateGoalStreak(goals), 3);
      });

      test('breaks streak on gap', () {
        final goals = [
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 7),
            status: GoalStatus.completed,
            completedAt: DateTime(2026, 2, 7),
          ),
          // Large gap here
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 3, 1),
            endDate: DateTime(2026, 3, 7),
            status: GoalStatus.completed,
            completedAt: DateTime(2026, 3, 7),
          ),
        ];

        // Should only count the most recent goal
        expect(repository.calculateGoalStreak(goals), 1);
      });

      test('returns 0 for empty goals list', () {
        expect(repository.calculateGoalStreak([]), 0);
      });

      test('returns 0 for no completed goals', () {
        final goals = [
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 7),
            status: GoalStatus.active,
          ),
        ];

        expect(repository.calculateGoalStreak(goals), 0);
      });
    });

    group('getCategoryStats', () {
      test('calculates statistics for each category', () {
        final goals = [
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 7),
            status: GoalStatus.completed,
          ),
          Goal(
            category: DayRatings.productivity,
            targetValue: 4.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 8),
            endDate: DateTime(2026, 2, 14),
            status: GoalStatus.failed,
          ),
          Goal(
            category: DayRatings.sport,
            targetValue: 3.0,
            timeframe: GoalTimeframe.weekly,
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 7),
            status: GoalStatus.completed,
          ),
        ];

        final stats = repository.getCategoryStats(goals);

        expect(stats[DayRatings.productivity]!.totalGoals, 2);
        expect(stats[DayRatings.productivity]!.completedGoals, 1);
        expect(stats[DayRatings.productivity]!.successRate, 0.5);
        expect(stats[DayRatings.productivity]!.failedGoals, 1);

        expect(stats[DayRatings.sport]!.totalGoals, 1);
        expect(stats[DayRatings.sport]!.completedGoals, 1);
        expect(stats[DayRatings.sport]!.successRate, 1.0);

        expect(stats[DayRatings.social]!.totalGoals, 0);
        expect(stats[DayRatings.social]!.successRate, 0.0);
      });

      test('handles empty goals list', () {
        final stats = repository.getCategoryStats([]);

        for (final category in DayRatings.values) {
          expect(stats[category]!.totalGoals, 0);
          expect(stats[category]!.completedGoals, 0);
          expect(stats[category]!.successRate, 0.0);
        }
      });
    });
  });

  group('CategoryGoalStats', () {
    test('calculates failed goals correctly', () {
      final stats = CategoryGoalStats(
        category: DayRatings.productivity,
        totalGoals: 10,
        completedGoals: 7,
        successRate: 0.7,
      );

      expect(stats.failedGoals, 3);
    });

    test('formats success rate as percentage', () {
      final stats = CategoryGoalStats(
        category: DayRatings.productivity,
        totalGoals: 10,
        completedGoals: 8,
        successRate: 0.8,
      );

      expect(stats.successRatePercent, '80%');
    });
  });
}
