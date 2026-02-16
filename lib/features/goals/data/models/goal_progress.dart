import 'package:day_tracker/features/goals/data/models/goal.dart';

enum ProgressStatus {
  onTrack, // Current average >= target or trending positively
  behind, // Current average < target and time running out
  ahead, // Current average significantly exceeds target
  completed, // Goal achieved
  failed, // Goal period ended without achieving target
}

class GoalProgress {
  final Goal goal;
  final double currentAverage;
  final int entriesCount;
  final double previousPeriodAverage;

  GoalProgress({
    required this.goal,
    required this.currentAverage,
    required this.entriesCount,
    this.previousPeriodAverage = 0.0,
  });

  /// Progress toward target (0.0 to 1.0+)
  /// Uses Endowed Progress Effect: show progress from baseline, not zero
  double get progressPercent {
    if (goal.targetValue <= 0) return 0.0;
    // Calculate progress from previous average as baseline
    final baseline = previousPeriodAverage > 0 ? previousPeriodAverage : 1.0;
    final targetGap = goal.targetValue - baseline;
    if (targetGap <= 0) return 1.0; // Already at or above target
    final currentGap = currentAverage - baseline;
    return (currentGap / targetGap).clamp(0.0, 1.5); // Allow overshoot display
  }

  /// Absolute progress (current / target)
  double get absoluteProgressPercent {
    if (goal.targetValue <= 0) return 0.0;
    return (currentAverage / goal.targetValue).clamp(0.0, 1.5);
  }

  /// Gap between current and target
  double get gap {
    return goal.targetValue - currentAverage;
  }

  /// Is the goal achieved?
  bool get isAchieved {
    return currentAverage >= goal.targetValue;
  }

  /// Determine current status based on progress and time
  ProgressStatus get status {
    if (goal.status == GoalStatus.completed) return ProgressStatus.completed;
    if (goal.status == GoalStatus.failed) return ProgressStatus.failed;

    if (isAchieved) {
      if (currentAverage >= goal.targetValue * 1.2) {
        return ProgressStatus.ahead;
      }
      return ProgressStatus.onTrack;
    }

    // Check if on track based on time elapsed vs progress
    final expectedProgress = goal.timeProgress;
    final actualProgress = absoluteProgressPercent;

    if (actualProgress >= expectedProgress * 0.9) {
      return ProgressStatus.onTrack;
    }
    return ProgressStatus.behind;
  }

  /// Human-readable status message
  String get statusMessage {
    switch (status) {
      case ProgressStatus.completed:
        return 'Goal achieved!';
      case ProgressStatus.ahead:
        return 'Exceeding target!';
      case ProgressStatus.onTrack:
        return 'On track';
      case ProgressStatus.behind:
        return 'Needs attention';
      case ProgressStatus.failed:
        return 'Goal not met';
    }
  }

  /// Points needed per day to reach target
  double get pointsNeededPerDay {
    if (goal.daysRemaining <= 0 || isAchieved) return 0;
    // Complex calculation considering existing entries
    final totalPointsNeeded = goal.targetValue * goal.totalDays;
    final pointsEarned = currentAverage * entriesCount;
    final pointsRemaining = totalPointsNeeded - pointsEarned;
    final daysWithNoEntry = goal.daysRemaining;
    return pointsRemaining / daysWithNoEntry;
  }

  /// Projection based on current trend
  double get projectedFinalAverage {
    if (entriesCount == 0) return previousPeriodAverage;
    return currentAverage; // Simple projection; could be enhanced with trend analysis
  }

  /// Whether projection meets target
  bool get projectedToSucceed {
    return projectedFinalAverage >= goal.targetValue;
  }
}
