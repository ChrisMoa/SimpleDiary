import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';

void main() {
  group('HabitEntry Model', () {
    test('creates entry with required fields', () {
      final entry = HabitEntry(
        habitId: 'habit-1',
        date: DateTime(2026, 2, 18),
      );

      expect(entry.habitId, 'habit-1');
      expect(entry.date, DateTime(2026, 2, 18));
      expect(entry.isCompleted, false);
      expect(entry.count, 0);
      expect(entry.note, '');
      expect(entry.id, isNotEmpty);
    });

    test('creates entry with all fields', () {
      final entry = HabitEntry(
        id: 'entry-1',
        habitId: 'habit-1',
        date: DateTime(2026, 2, 18),
        isCompleted: true,
        count: 3,
        note: 'Felt great today',
      );

      expect(entry.id, 'entry-1');
      expect(entry.isCompleted, true);
      expect(entry.count, 3);
      expect(entry.note, 'Felt great today');
    });

    test('dateKey returns correct format', () {
      final entry = HabitEntry(
        habitId: 'habit-1',
        date: DateTime(2026, 2, 8),
      );

      expect(entry.dateKey, '2026-02-08');
    });

    test('dateKey pads single-digit months and days', () {
      final entry = HabitEntry(
        habitId: 'habit-1',
        date: DateTime(2026, 1, 5),
      );

      expect(entry.dateKey, '2026-01-05');
    });

    test('getId returns id', () {
      final entry = HabitEntry(
        id: 'my-entry',
        habitId: 'h1',
        date: DateTime(2026, 2, 18),
      );

      expect(entry.getId(), 'my-entry');
    });

    test('primaryKeyValue returns id', () {
      final entry = HabitEntry(
        id: 'my-entry',
        habitId: 'h1',
        date: DateTime(2026, 2, 18),
      );

      expect(entry.primaryKeyValue, 'my-entry');
    });

    test('serializes to and from database map correctly', () {
      final entry = HabitEntry(
        id: 'entry-1',
        habitId: 'habit-1',
        date: DateTime(2026, 2, 18),
        isCompleted: true,
        count: 2,
        note: 'Good session',
      );

      final map = entry.toDbMap();
      final deserialized = HabitEntry.fromDbMap(map);

      expect(deserialized.id, entry.id);
      expect(deserialized.habitId, entry.habitId);
      expect(deserialized.date, entry.date);
      expect(deserialized.isCompleted, entry.isCompleted);
      expect(deserialized.count, entry.count);
      expect(deserialized.note, entry.note);
    });

    test('backward compat: toLocalDbMap/fromLocalDbMap round-trip', () {
      final entry = HabitEntry(
        id: 'entry-1',
        habitId: 'habit-1',
        date: DateTime(2026, 2, 18),
        isCompleted: true,
        count: 2,
        note: 'Good session',
      );

      final map = entry.toLocalDbMap(entry);
      final deserialized = entry.fromLocalDbMap(map);

      expect(deserialized.id, entry.id);
      expect(deserialized.habitId, entry.habitId);
    });

    test('serializes boolean as integer in database map', () {
      final completedEntry = HabitEntry(
        habitId: 'h1',
        date: DateTime(2026, 2, 18),
        isCompleted: true,
      );
      final notCompletedEntry = HabitEntry(
        habitId: 'h1',
        date: DateTime(2026, 2, 18),
        isCompleted: false,
      );

      expect(completedEntry.toDbMap()['isCompleted'], 1);
      expect(notCompletedEntry.toDbMap()['isCompleted'], 0);
    });

    test('copyWith updates fields correctly', () {
      final entry = HabitEntry(
        id: 'entry-1',
        habitId: 'habit-1',
        date: DateTime(2026, 2, 18),
        isCompleted: false,
        count: 0,
        note: '',
      );

      final updated = entry.copyWith(
        isCompleted: true,
        count: 1,
        note: 'Done!',
      );

      expect(updated.isCompleted, true);
      expect(updated.count, 1);
      expect(updated.note, 'Done!');
      expect(updated.id, entry.id); // ID preserved
      expect(updated.habitId, entry.habitId); // habitId preserved
      expect(updated.date, entry.date); // date preserved
    });

    test('copyWith preserves fields when not specified', () {
      final entry = HabitEntry(
        habitId: 'h1',
        date: DateTime(2026, 2, 18),
        isCompleted: true,
        count: 5,
        note: 'Original note',
      );

      final updated = entry.copyWith(isCompleted: false);

      expect(updated.isCompleted, false);
      expect(updated.count, 5);
      expect(updated.note, 'Original note');
    });

    test('columns define correct schema', () {
      expect(HabitEntry.columns.length, 6);
      expect(
        HabitEntry.columns.where((c) => c.isPrimaryKey).single.name,
        'id',
      );
    });
  });
}
