import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';

class HabitStats {
  final int currentStreak;
  final int bestStreak;
  final double completionRate7d;
  final double completionRate30d;
  final double completionRateAll;
  final int totalCompletions;

  const HabitStats({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completionRate7d = 0.0,
    this.completionRate30d = 0.0,
    this.completionRateAll = 0.0,
    this.totalCompletions = 0,
  });
}

class HabitGridDay {
  final DateTime date;
  final double completionRatio; // 0.0 to 1.0

  const HabitGridDay({required this.date, required this.completionRatio});
}

class HabitsRepository {
  /// Calculate the current streak for a habit.
  /// Streak counts consecutive due days where the habit was completed,
  /// going backwards from today (or yesterday if today is not yet completed).
  int getCurrentStreak(Habit habit, List<HabitEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDates = _getCompletedDateSet(entries);

    int streak = 0;
    var checkDate = today;

    // If today is due but not completed, start from yesterday
    if (habit.isDueOnDay(checkDate) && !completedDates.contains(_dateKey(checkDate))) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      if (checkDate.isBefore(DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day))) {
        break;
      }

      if (!habit.isDueOnDay(checkDate)) {
        // Skip non-due days (they don't break streaks)
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      if (completedDates.contains(_dateKey(checkDate))) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate the best (longest) streak ever for a habit.
  int getBestStreak(Habit habit, List<HabitEntry> entries) {
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final completedDates = _getCompletedDateSet(entries);

    int bestStreak = 0;
    int currentStreak = 0;
    var checkDate = createdDate;

    while (!checkDate.isAfter(today)) {
      if (!habit.isDueOnDay(checkDate)) {
        checkDate = checkDate.add(const Duration(days: 1));
        continue;
      }

      if (completedDates.contains(_dateKey(checkDate))) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return bestStreak;
  }

  /// Calculate completion rate for a habit over the given number of days.
  double getCompletionRate(Habit habit, List<HabitEntry> entries, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));
    final completedDates = _getCompletedDateSet(entries);

    int dueDays = 0;
    int completedDays = 0;

    var checkDate = startDate;
    while (!checkDate.isAfter(today)) {
      if (habit.isDueOnDay(checkDate)) {
        dueDays++;
        if (completedDates.contains(_dateKey(checkDate))) {
          completedDays++;
        }
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    if (dueDays == 0) return 0.0;
    return completedDays / dueDays;
  }

  /// Get stats for a single habit.
  HabitStats getHabitStats(Habit habit, List<HabitEntry> habitEntries) {
    final completedEntries = habitEntries.where((e) => e.isCompleted).toList();
    return HabitStats(
      currentStreak: getCurrentStreak(habit, habitEntries),
      bestStreak: getBestStreak(habit, habitEntries),
      completionRate7d: getCompletionRate(habit, habitEntries, 7),
      completionRate30d: getCompletionRate(habit, habitEntries, 30),
      completionRateAll: _getAllTimeCompletionRate(habit, habitEntries),
      totalCompletions: completedEntries.length,
    );
  }

  /// Generate grid data for the contribution graph (last 52 weeks).
  /// Returns a map from date key to completion ratio (0.0-1.0) across all active habits.
  List<HabitGridDay> getGridData(List<Habit> habits, List<HabitEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Start from the most recent Sunday going back ~52 weeks
    final gridEnd = today;
    final gridStart = today.subtract(const Duration(days: 364)); // 52 weeks

    final activeHabits = habits.where((h) => !h.isArchived).toList();
    if (activeHabits.isEmpty) return [];

    // Build a lookup: dateKey -> set of completed habitIds
    final Map<String, Set<String>> completedByDate = {};
    for (final entry in entries) {
      if (entry.isCompleted) {
        completedByDate.putIfAbsent(entry.dateKey, () => {}).add(entry.habitId);
      }
    }

    final List<HabitGridDay> gridDays = [];
    var checkDate = gridStart;

    while (!checkDate.isAfter(gridEnd)) {
      final dueHabits = activeHabits.where((h) => h.isDueOnDay(checkDate)).toList();
      final dateKey = _dateKey(checkDate);
      final completedSet = completedByDate[dateKey] ?? {};

      double ratio = 0.0;
      if (dueHabits.isNotEmpty) {
        final completedCount = dueHabits.where((h) => completedSet.contains(h.id)).length;
        ratio = completedCount / dueHabits.length;
      }

      gridDays.add(HabitGridDay(date: checkDate, completionRatio: ratio));
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return gridDays;
  }

  /// Get today's progress: (completed habits / total due habits).
  double getTodayProgress(List<Habit> habits, List<HabitEntry> todayEntries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueHabits = habits.where((h) => !h.isArchived && h.isDueOnDay(today)).toList();
    if (dueHabits.isEmpty) return 1.0;

    final completedIds = todayEntries
        .where((e) => e.isCompleted)
        .map((e) => e.habitId)
        .toSet();

    final completedCount = dueHabits.where((h) => completedIds.contains(h.id)).length;
    return completedCount / dueHabits.length;
  }

  // -- Private helpers --

  double _getAllTimeCompletionRate(Habit habit, List<HabitEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final totalDays = today.difference(createdDate).inDays + 1;
    if (totalDays <= 0) return 0.0;
    return getCompletionRate(habit, entries, totalDays);
  }

  Set<String> _getCompletedDateSet(List<HabitEntry> entries) {
    return entries
        .where((e) => e.isCompleted)
        .map((e) => e.dateKey)
        .toSet();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
