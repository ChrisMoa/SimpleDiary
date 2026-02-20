import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/core/database/db_provider_factory.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/models/goal_progress.dart';
import 'package:day_tracker/features/goals/data/repositories/goal_repository.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';

/// Goal provider — migrated to schema-driven DbRepository.
final goalsLocalDbDataProvider = createDbProvider<Goal>(
  tableName: Goal.tableName,
  columns: Goal.columns,
  fromMap: Goal.fromDbMap,
  migrations: Goal.migrations,
);

/// Repository provider
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

/// Active goals with progress
final activeGoalsWithProgressProvider = Provider<List<GoalProgress>>((ref) {
  final goals = ref.watch(goalsLocalDbDataProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final repository = ref.watch(goalRepositoryProvider);

  final activeGoals = goals.where((g) => g.isInProgress).toList();

  return activeGoals.map((goal) {
    // Get previous period days for baseline
    final previousStart = goal.startDate.subtract(
      Duration(days: goal.totalDays),
    );
    final previousDays = diaryDays
        .where((day) =>
            !day.day.isBefore(previousStart) && day.day.isBefore(goal.startDate))
        .toList();

    return repository.calculateProgress(
      goal: goal,
      diaryDays: diaryDays,
      previousPeriodDays: previousDays,
    );
  }).toList();
});

/// Goal streak count
final goalStreakProvider = Provider<int>((ref) {
  final goals = ref.watch(goalsLocalDbDataProvider);
  final repository = ref.watch(goalRepositoryProvider);
  return repository.calculateGoalStreak(goals);
});

/// Category statistics
final categoryGoalStatsProvider =
    Provider<Map<DayRatings, CategoryGoalStats>>((ref) {
  final goals = ref.watch(goalsLocalDbDataProvider);
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getCategoryStats(goals);
});

/// Target suggestion for creating new goals
final targetSuggestionProvider =
    Provider.family<double, DayRatings>((ref, category) {
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final repository = ref.watch(goalRepositoryProvider);

  // Use last 30 days for suggestion
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final recentDays =
      diaryDays.where((d) => d.day.isAfter(thirtyDaysAgo)).toList();

  return repository.suggestTarget(
    category: category,
    diaryDays: recentDays,
  );
});

/// Check and update goal completions
final goalCompletionCheckerProvider = Provider<void>((ref) {
  final goals = ref.watch(goalsLocalDbDataProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final repository = ref.watch(goalRepositoryProvider);
  final notifier = ref.read(goalsLocalDbDataProvider.notifier);

  final updatedGoals = repository.checkGoalCompletions(
    goals: goals,
    diaryDays: diaryDays,
  );

  for (final goal in updatedGoals) {
    notifier.addOrUpdateElement(goal);
  }
});
