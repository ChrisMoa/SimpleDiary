import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/core/database/abstract_local_db_provider_state.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/habits/data/repositories/habits_local_db.dart';
import 'package:day_tracker/features/habits/data/repositories/habit_entries_local_db.dart';
import 'package:day_tracker/features/habits/data/repositories/habits_repository.dart';

/// Database provider for habits
class HabitDataProvider extends AbstractLocalDbProviderState<Habit> {
  HabitDataProvider() : super(tableName: 'habits', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return HabitsLocalDbHelper(
      tableName: tableName,
      primaryKey: primaryKey,
      dbFile: dbFile,
    );
  }
}

/// Database provider for habit entries
class HabitEntryDataProvider extends AbstractLocalDbProviderState<HabitEntry> {
  HabitEntryDataProvider()
      : super(tableName: 'habit_entries', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return HabitEntriesLocalDbHelper(
      tableName: tableName,
      primaryKey: primaryKey,
      dbFile: dbFile,
    );
  }
}

// -- StateNotifier providers --

final habitsLocalDbDataProvider =
    StateNotifierProvider<HabitDataProvider, List<Habit>>((ref) {
  return HabitDataProvider();
});

final habitEntriesLocalDbDataProvider =
    StateNotifierProvider<HabitEntryDataProvider, List<HabitEntry>>((ref) {
  return HabitEntryDataProvider();
});

// -- Repository --

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository();
});

// -- Derived providers --

/// Active (non-archived) habits
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsLocalDbDataProvider);
  return habits.where((h) => !h.isArchived).toList();
});

/// Habits that are due today
final todayHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(activeHabitsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return habits.where((h) => h.isDueOnDay(today)).toList();
});

/// Today's entries for quick lookup
final todayEntriesProvider = Provider<List<HabitEntry>>((ref) {
  final entries = ref.watch(habitEntriesLocalDbDataProvider);
  final now = DateTime.now();
  final todayKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return entries.where((e) => e.dateKey == todayKey).toList();
});

/// Today's progress ratio (0.0 - 1.0)
final todayProgressProvider = Provider<double>((ref) {
  final habits = ref.watch(activeHabitsProvider);
  final todayEntries = ref.watch(todayEntriesProvider);
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.getTodayProgress(habits, todayEntries);
});

/// Per-habit stats, keyed by habit ID
final habitStatsProvider =
    Provider.family<HabitStats, String>((ref, habitId) {
  final habits = ref.watch(habitsLocalDbDataProvider);
  final entries = ref.watch(habitEntriesLocalDbDataProvider);
  final repository = ref.watch(habitsRepositoryProvider);

  final habit = habits.where((h) => h.id == habitId).firstOrNull;
  if (habit == null) return const HabitStats();

  final habitEntries = entries.where((e) => e.habitId == habitId).toList();
  return repository.getHabitStats(habit, habitEntries);
});

/// Grid data for contribution graph
final habitGridDataProvider = Provider<List<HabitGridDay>>((ref) {
  final habits = ref.watch(activeHabitsProvider);
  final entries = ref.watch(habitEntriesLocalDbDataProvider);
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.getGridData(habits, entries);
});
