import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';
import 'package:day_tracker/features/habits/data/repositories/habits_repository.dart';

void main() {
  late HabitsRepository repository;

  setUp(() {
    repository = HabitsRepository();
  });

  group('getCurrentStreak', () {
    test('returns 0 for no entries', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2026, 2, 1),
      );

      expect(repository.getCurrentStreak(habit, []), 0);
    });

    test('counts consecutive completed days going backwards', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 10)),
      );

      final entries = [
        HabitEntry(
          habitId: habit.id,
          date: today.subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        HabitEntry(
          habitId: habit.id,
          date: today.subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        HabitEntry(
          habitId: habit.id,
          date: today,
          isCompleted: true,
        ),
      ];

      expect(repository.getCurrentStreak(habit, entries), 3);
    });

    test('streak breaks on missing day', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 10)),
      );

      // Gap on day -2
      final entries = [
        HabitEntry(
          habitId: habit.id,
          date: today.subtract(const Duration(days: 3)),
          isCompleted: true,
        ),
        HabitEntry(
          habitId: habit.id,
          date: today.subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        HabitEntry(
          habitId: habit.id,
          date: today,
          isCompleted: true,
        ),
      ];

      expect(repository.getCurrentStreak(habit, entries), 2);
    });

    test('skips non-due days for weekday habits', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        name: 'Work habit',
        frequency: HabitFrequency.weekdays,
        createdAt: today.subtract(const Duration(days: 30)),
      );

      // Build entries for every weekday going backwards from today
      final entries = <HabitEntry>[];
      var checkDate = today;
      int weekdaysAdded = 0;
      while (weekdaysAdded < 5) {
        if (checkDate.weekday >= DateTime.monday &&
            checkDate.weekday <= DateTime.friday) {
          entries.add(HabitEntry(
              habitId: habit.id, date: checkDate, isCompleted: true));
          weekdaysAdded++;
        }
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      final streak = repository.getCurrentStreak(habit, entries);
      // All recent weekdays are completed, weekends skipped
      expect(streak, greaterThanOrEqualTo(3));
    });
  });

  group('getBestStreak', () {
    test('returns 0 for no entries', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2026, 2, 1),
      );

      expect(repository.getBestStreak(habit, []), 0);
    });

    test('returns best streak across history', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2026, 2, 1),
      );

      final entries = [
        // First streak of 3
        HabitEntry(
            habitId: habit.id,
            date: DateTime(2026, 2, 1),
            isCompleted: true),
        HabitEntry(
            habitId: habit.id,
            date: DateTime(2026, 2, 2),
            isCompleted: true),
        HabitEntry(
            habitId: habit.id,
            date: DateTime(2026, 2, 3),
            isCompleted: true),
        // Gap on Feb 4
        // Second streak of 2
        HabitEntry(
            habitId: habit.id,
            date: DateTime(2026, 2, 5),
            isCompleted: true),
        HabitEntry(
            habitId: habit.id,
            date: DateTime(2026, 2, 6),
            isCompleted: true),
      ];

      expect(repository.getBestStreak(habit, entries), 3);
    });
  });

  group('getCompletionRate', () {
    test('returns 0 for no entries', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2026, 2, 1),
      );

      expect(repository.getCompletionRate(habit, [], 7), 0.0);
    });

    test('calculates correct rate for daily habit', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 30)),
      );

      // Complete 5 out of last 7 days
      final entries = List.generate(5, (i) {
        return HabitEntry(
          habitId: habit.id,
          date: today.subtract(Duration(days: i)),
          isCompleted: true,
        );
      });

      final rate = repository.getCompletionRate(habit, entries, 7);
      expect(rate, closeTo(5 / 7, 0.01));
    });
  });

  group('getHabitStats', () {
    test('returns default stats for empty entries', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2026, 2, 18),
      );

      final stats = repository.getHabitStats(habit, []);

      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
      expect(stats.totalCompletions, 0);
    });

    test('calculates total completions', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 10)),
      );

      final entries = [
        HabitEntry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 2)),
            isCompleted: true),
        HabitEntry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            isCompleted: true),
        HabitEntry(
            habitId: habit.id,
            date: today,
            isCompleted: false), // Not completed
      ];

      final stats = repository.getHabitStats(habit, entries);
      expect(stats.totalCompletions, 2);
    });
  });

  group('getGridData', () {
    test('returns empty for no habits', () {
      final result = repository.getGridData([], []);
      expect(result, isEmpty);
    });

    test('returns 365 days of data', () {
      final habit = Habit(
        name: 'Test',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2025, 1, 1),
      );

      final result = repository.getGridData([habit], []);
      expect(result.length, 365);
    });

    test('calculates completion ratio correctly', () {
      final habit1 = Habit(
        id: 'h1',
        name: 'Habit 1',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2025, 1, 1),
      );
      final habit2 = Habit(
        id: 'h2',
        name: 'Habit 2',
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2025, 1, 1),
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Only habit1 completed today
      final entries = [
        HabitEntry(
            habitId: 'h1', date: today, isCompleted: true),
      ];

      final result = repository.getGridData([habit1, habit2], entries);
      final todayData = result.last;
      expect(todayData.completionRatio, closeTo(0.5, 0.01));
    });
  });

  group('getTodayProgress', () {
    test('returns 1.0 when no habits are due', () {
      final progress = repository.getTodayProgress([], []);
      expect(progress, 1.0);
    });

    test('returns correct ratio', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit1 = Habit(id: 'h1', name: 'H1', frequency: HabitFrequency.daily);
      final habit2 = Habit(id: 'h2', name: 'H2', frequency: HabitFrequency.daily);

      final entries = [
        HabitEntry(habitId: 'h1', date: today, isCompleted: true),
      ];

      final progress = repository.getTodayProgress([habit1, habit2], entries);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('returns 1.0 when all habits completed', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit1 = Habit(id: 'h1', name: 'H1', frequency: HabitFrequency.daily);

      final entries = [
        HabitEntry(habitId: 'h1', date: today, isCompleted: true),
      ];

      final progress = repository.getTodayProgress([habit1], entries);
      expect(progress, 1.0);
    });
  });
}
