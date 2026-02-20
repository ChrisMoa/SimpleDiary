import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';

void main() {
  group('Goal Model', () {
    test('creates goal with required fields', () {
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 16),
      );

      expect(goal.category, DayRatings.productivity);
      expect(goal.targetValue, 4.0);
      expect(goal.timeframe, GoalTimeframe.weekly);
      expect(goal.status, GoalStatus.active);
      expect(goal.id, isNotEmpty);
    });

    test('weekly factory creates correct date range', () {
      final startDate = DateTime(2026, 2, 10); // Monday
      final goal = Goal.weekly(
        category: DayRatings.sport,
        targetValue: 3.5,
        startDate: startDate,
      );

      expect(goal.timeframe, GoalTimeframe.weekly);
      expect(goal.startDate, startDate);
      expect(goal.endDate, DateTime(2026, 2, 16)); // Sunday
      expect(goal.totalDays, 7);
    });

    test('monthly factory creates correct date range', () {
      final goal = Goal.monthly(
        category: DayRatings.social,
        targetValue: 4.5,
        startDate: DateTime(2026, 2, 1),
      );

      expect(goal.timeframe, GoalTimeframe.monthly);
      expect(goal.startDate, DateTime(2026, 2, 1));
      expect(goal.endDate, DateTime(2026, 2, 28)); // Last day of February 2026
    });

    test('calculates days remaining correctly', () {
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
      );

      expect(goal.daysRemaining, greaterThanOrEqualTo(5));
      expect(goal.daysRemaining, lessThanOrEqualTo(6));
    });

    test('calculates days elapsed correctly', () {
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3)),
      );

      expect(goal.daysElapsed, greaterThanOrEqualTo(3));
      expect(goal.daysElapsed, lessThanOrEqualTo(4));
    });

    test('calculates time progress correctly', () {
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3)),
      );

      expect(goal.timeProgress, greaterThanOrEqualTo(0.4));
      expect(goal.timeProgress, lessThanOrEqualTo(0.6));
    });

    test('isInProgress returns true for active goal in period', () {
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 4)),
        status: GoalStatus.active,
      );

      expect(goal.isInProgress, isTrue);
    });

    test('isInProgress returns false for completed goal', () {
      final now = DateTime.now();
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 4)),
        status: GoalStatus.completed,
      );

      expect(goal.isInProgress, isFalse);
    });

    test('hasEnded returns true for past goal', () {
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 7),
      );

      expect(goal.hasEnded, isTrue);
    });

    test('serializes to and from database map correctly', () {
      final goal = Goal(
        id: 'test-id',
        category: DayRatings.sport,
        targetValue: 3.5,
        timeframe: GoalTimeframe.monthly,
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
        status: GoalStatus.active,
        createdAt: DateTime(2026, 2, 1, 10, 0),
      );

      final map = goal.toDbMap();
      final deserialized = Goal.fromDbMap(map);

      expect(deserialized.id, goal.id);
      expect(deserialized.category, goal.category);
      expect(deserialized.targetValue, goal.targetValue);
      expect(deserialized.timeframe, goal.timeframe);
      expect(deserialized.startDate, goal.startDate);
      expect(deserialized.endDate, goal.endDate);
      expect(deserialized.status, goal.status);
      expect(deserialized.createdAt, goal.createdAt);
    });

    test('copyWith updates status correctly', () {
      final goal = Goal(
        category: DayRatings.productivity,
        targetValue: 4.0,
        timeframe: GoalTimeframe.weekly,
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 16),
        status: GoalStatus.active,
      );

      final completed = goal.copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime(2026, 2, 16),
      );

      expect(completed.status, GoalStatus.completed);
      expect(completed.completedAt, isNotNull);
      expect(completed.id, goal.id);
      expect(completed.category, goal.category);
    });
  });

  group('Goal Enums', () {
    test('GoalTimeframe has correct values', () {
      expect(GoalTimeframe.values.length, 2);
      expect(GoalTimeframe.weekly.index, 0);
      expect(GoalTimeframe.monthly.index, 1);
    });

    test('GoalStatus has correct values', () {
      expect(GoalStatus.values.length, 4);
      expect(GoalStatus.active.index, 0);
      expect(GoalStatus.completed.index, 1);
      expect(GoalStatus.failed.index, 2);
      expect(GoalStatus.archived.index, 3);
    });
  });
}
