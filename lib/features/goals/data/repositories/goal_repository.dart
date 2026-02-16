import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/models/goal_progress.dart';

class GoalRepository {
  /// Calculate progress for a specific goal
  GoalProgress calculateProgress({
    required Goal goal,
    required List<DiaryDay> diaryDays,
    required List<DiaryDay> previousPeriodDays,
  }) {
    // Filter diary days within goal period
    final relevantDays = diaryDays
        .where((day) =>
            !day.day.isBefore(goal.startDate) && !day.day.isAfter(goal.endDate))
        .toList();

    // Get ratings for the goal's category
    final ratings = <int>[];
    for (final day in relevantDays) {
      final rating = day.ratings.firstWhere(
        (r) => r.dayRating == goal.category,
        orElse: () => DayRating(dayRating: goal.category, score: -1),
      );
      if (rating.score >= 0) {
        ratings.add(rating.score);
      }
    }

    final currentAverage =
        ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

    // Calculate previous period average for baseline
    final previousRatings = <int>[];
    for (final day in previousPeriodDays) {
      final rating = day.ratings.firstWhere(
        (r) => r.dayRating == goal.category,
        orElse: () => DayRating(dayRating: goal.category, score: -1),
      );
      if (rating.score >= 0) {
        previousRatings.add(rating.score);
      }
    }

    final previousAverage = previousRatings.isEmpty
        ? 0.0
        : previousRatings.reduce((a, b) => a + b) / previousRatings.length;

    return GoalProgress(
      goal: goal,
      currentAverage: currentAverage,
      entriesCount: ratings.length,
      previousPeriodAverage: previousAverage,
    );
  }

  /// Get smart target suggestion based on historical data
  double suggestTarget({
    required DayRatings category,
    required List<DiaryDay> diaryDays,
    double improvementFactor = 0.15, // 15% improvement target
  }) {
    final ratings = <int>[];
    for (final day in diaryDays) {
      final rating = day.ratings.firstWhere(
        (r) => r.dayRating == category,
        orElse: () => DayRating(dayRating: category, score: -1),
      );
      if (rating.score >= 0) {
        ratings.add(rating.score);
      }
    }

    if (ratings.isEmpty) return 3.0; // Default starting target

    final currentAverage = ratings.reduce((a, b) => a + b) / ratings.length;
    final suggestedTarget = currentAverage * (1 + improvementFactor);

    // Clamp to valid range (1.0 - 5.0)
    return suggestedTarget.clamp(1.0, 5.0);
  }

  /// Check for goals that need status updates
  List<Goal> checkGoalCompletions({
    required List<Goal> goals,
    required List<DiaryDay> diaryDays,
  }) {
    final updatedGoals = <Goal>[];

    for (final goal in goals.where((g) => g.status == GoalStatus.active)) {
      if (!goal.hasEnded) continue;

      // Calculate final progress
      final progress = calculateProgress(
        goal: goal,
        diaryDays: diaryDays,
        previousPeriodDays: [],
      );

      if (progress.isAchieved) {
        updatedGoals.add(goal.copyWith(
          status: GoalStatus.completed,
          completedAt: DateTime.now(),
        ));
      } else {
        updatedGoals.add(goal.copyWith(
          status: GoalStatus.failed,
        ));
      }
    }

    return updatedGoals;
  }

  /// Calculate goal achievement streak
  int calculateGoalStreak(List<Goal> goals) {
    final completedGoals = goals
        .where((g) => g.status == GoalStatus.completed)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (completedGoals.isEmpty) return 0;

    int streak = 0;
    DateTime? lastEndDate;

    for (final goal in completedGoals) {
      if (lastEndDate == null) {
        streak = 1;
        lastEndDate = goal.endDate;
        continue;
      }

      // Check if this goal period is adjacent to the previous
      final gapDays = lastEndDate.difference(goal.endDate).inDays.abs();
      if (gapDays <= 7) {
        // Allow weekly goal gaps
        streak++;
        lastEndDate = goal.endDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get category performance summary
  Map<DayRatings, CategoryGoalStats> getCategoryStats(List<Goal> goals) {
    final stats = <DayRatings, CategoryGoalStats>{};

    for (final category in DayRatings.values) {
      final categoryGoals = goals.where((g) => g.category == category).toList();
      final completed =
          categoryGoals.where((g) => g.status == GoalStatus.completed).length;
      final total = categoryGoals.length;

      stats[category] = CategoryGoalStats(
        category: category,
        totalGoals: total,
        completedGoals: completed,
        successRate: total > 0 ? completed / total : 0,
      );
    }

    return stats;
  }
}

class CategoryGoalStats {
  final DayRatings category;
  final int totalGoals;
  final int completedGoals;
  final double successRate;

  CategoryGoalStats({
    required this.category,
    required this.totalGoals,
    required this.completedGoals,
    required this.successRate,
  });

  int get failedGoals => totalGoals - completedGoals;
  String get successRatePercent =>
      '${(successRate * 100).toStringAsFixed(0)}%';
}
