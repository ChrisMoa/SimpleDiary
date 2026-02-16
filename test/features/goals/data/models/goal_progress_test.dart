import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/models/goal_progress.dart';

void main() {
  group('GoalProgress', () {
    late Goal testGoal;

    setUp(() {
      testGoal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 16),
      );
    });

    test('calculates absolute progress percent correctly', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.0,
        entriesCount: 5,
      );

      expect(progress.absoluteProgressPercent, closeTo(0.75, 0.01));
    });

    test('calculates gap correctly', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.5,
        entriesCount: 5,
      );

      expect(progress.gap, closeTo(0.5, 0.01));
    });

    test('isAchieved returns true when target is met', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 4.0,
        entriesCount: 5,
      );

      expect(progress.isAchieved, isTrue);
    });

    test('isAchieved returns false when target is not met', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.5,
        entriesCount: 5,
      );

      expect(progress.isAchieved, isFalse);
    });

    test('status is completed for completed goal', () {
      final completedGoal = testGoal.copyWith(status: GoalStatus.completed);
      final progress = GoalProgress(
        goal: completedGoal,
        currentAverage: 4.0,
        entriesCount: 5,
      );

      expect(progress.status, ProgressStatus.completed);
    });

    test('status is ahead when significantly exceeding target', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 4.8, // 20% above target
        entriesCount: 5,
      );

      expect(progress.status, ProgressStatus.ahead);
    });

    test('status is onTrack when meeting target', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 4.0,
        entriesCount: 5,
      );

      expect(progress.status, ProgressStatus.onTrack);
    });

    test('status is behind when below expected progress', () {
      // Create goal that's 50% through time but only 25% through target
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3)),
      );

      final progress = GoalProgress(
        goal: goal,
        currentAverage: 1.0, // Only 25% of target
        entriesCount: 3,
      );

      expect(progress.status, ProgressStatus.behind);
    });

    test('statusMessage returns correct message for each status', () {
      expect(
        GoalProgress(
          goal: testGoal.copyWith(status: GoalStatus.completed),
          currentAverage: 4.0,
          entriesCount: 5,
        ).statusMessage,
        'Goal achieved!',
      );

      expect(
        GoalProgress(
          goal: testGoal,
          currentAverage: 4.8,
          entriesCount: 5,
        ).statusMessage,
        'Exceeding target!',
      );

      expect(
        GoalProgress(
          goal: testGoal,
          currentAverage: 4.0,
          entriesCount: 5,
        ).statusMessage,
        'On track',
      );
    });

    test('projectedFinalAverage returns current average when entries exist', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.5,
        entriesCount: 5,
      );

      expect(progress.projectedFinalAverage, 3.5);
    });

    test('projectedFinalAverage returns previous average when no entries', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 0.0,
        entriesCount: 0,
        previousPeriodAverage: 3.0,
      );

      expect(progress.projectedFinalAverage, 3.0);
    });

    test('projectedToSucceed returns true when projection meets target', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 4.2,
        entriesCount: 5,
      );

      expect(progress.projectedToSucceed, isTrue);
    });

    test('projectedToSucceed returns false when projection fails target', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.0,
        entriesCount: 5,
      );

      expect(progress.projectedToSucceed, isFalse);
    });

    test('endowed progress effect uses previous baseline', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 3.5,
        entriesCount: 5,
        previousPeriodAverage: 3.0,
      );

      // Progress from 3.0 to 3.5 toward 4.0 = 0.5/1.0 = 50%
      expect(progress.progressPercent, closeTo(0.5, 0.01));
    });

    test('progressPercent clamps to maximum of 1.5', () {
      final progress = GoalProgress(
        goal: testGoal,
        currentAverage: 8.0, // Far exceeding target
        entriesCount: 5,
        previousPeriodAverage: 3.0,
      );

      expect(progress.progressPercent, 1.5);
    });
  });

  group('ProgressStatus Enum', () {
    test('has correct values', () {
      expect(ProgressStatus.values.length, 5);
      expect(ProgressStatus.onTrack.index, 0);
      expect(ProgressStatus.behind.index, 1);
      expect(ProgressStatus.ahead.index, 2);
      expect(ProgressStatus.completed.index, 3);
      expect(ProgressStatus.failed.index, 4);
    });
  });
}
