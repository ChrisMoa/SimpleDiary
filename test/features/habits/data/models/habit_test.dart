import 'package:flutter_test/flutter_test.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';

void main() {
  group('Habit Model', () {
    test('creates habit with required fields', () {
      final habit = Habit(name: 'Read 30 min');

      expect(habit.name, 'Read 30 min');
      expect(habit.id, isNotEmpty);
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.targetCount, 1);
      expect(habit.isArchived, false);
    });

    test('creates habit with all fields', () {
      final habit = Habit(
        id: 'test-id',
        name: 'Meditate',
        description: 'Morning meditation',
        iconCodePoint: 0xe000,
        colorValue: 0xFF2196F3,
        frequency: HabitFrequency.weekdays,
        targetCount: 2,
        specificDays: [1, 3, 5],
        timesPerWeek: 3,
        createdAt: DateTime(2026, 2, 1),
        isArchived: false,
      );

      expect(habit.id, 'test-id');
      expect(habit.name, 'Meditate');
      expect(habit.description, 'Morning meditation');
      expect(habit.iconCodePoint, 0xe000);
      expect(habit.colorValue, 0xFF2196F3);
      expect(habit.frequency, HabitFrequency.weekdays);
      expect(habit.targetCount, 2);
      expect(habit.specificDays, [1, 3, 5]);
      expect(habit.timesPerWeek, 3);
      expect(habit.createdAt, DateTime(2026, 2, 1));
    });

    test('serializes to and from database map correctly', () {
      final habit = Habit(
        id: 'test-id',
        name: 'Exercise',
        description: 'Daily workout',
        iconCodePoint: 0xe156,
        colorValue: 0xFF4CAF50,
        frequency: HabitFrequency.specificDays,
        targetCount: 1,
        specificDays: [1, 2, 3, 4, 5],
        timesPerWeek: 5,
        createdAt: DateTime(2026, 2, 1, 10, 0),
        isArchived: false,
      );

      final map = habit.toDbMap();
      final deserialized = Habit.fromDbMap(map);

      expect(deserialized.id, habit.id);
      expect(deserialized.name, habit.name);
      expect(deserialized.description, habit.description);
      expect(deserialized.iconCodePoint, habit.iconCodePoint);
      expect(deserialized.colorValue, habit.colorValue);
      expect(deserialized.frequency, habit.frequency);
      expect(deserialized.targetCount, habit.targetCount);
      expect(deserialized.specificDays, habit.specificDays);
      expect(deserialized.timesPerWeek, habit.timesPerWeek);
      expect(deserialized.createdAt, habit.createdAt);
      expect(deserialized.isArchived, habit.isArchived);
    });

    test('serializes archived habit correctly', () {
      final habit = Habit(
        id: 'archived-id',
        name: 'Old habit',
        isArchived: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = habit.toDbMap();
      expect(map['isArchived'], 1);

      final deserialized = Habit.fromDbMap(map);
      expect(deserialized.isArchived, true);
    });

    test('primaryKeyValue returns id', () {
      final habit = Habit(id: 'my-id', name: 'Test');
      expect(habit.primaryKeyValue, 'my-id');
    });

    test('copyWith updates fields correctly', () {
      final habit = Habit(
        name: 'Original',
        frequency: HabitFrequency.daily,
        isArchived: false,
      );

      final updated = habit.copyWith(
        name: 'Updated',
        isArchived: true,
        frequency: HabitFrequency.weekends,
      );

      expect(updated.name, 'Updated');
      expect(updated.isArchived, true);
      expect(updated.frequency, HabitFrequency.weekends);
      expect(updated.id, habit.id); // ID preserved
      expect(updated.createdAt, habit.createdAt); // createdAt preserved
    });

    test('copyWith preserves fields when not specified', () {
      final habit = Habit(
        name: 'Test',
        description: 'A description',
        targetCount: 3,
      );

      final updated = habit.copyWith(name: 'New name');

      expect(updated.name, 'New name');
      expect(updated.description, 'A description');
      expect(updated.targetCount, 3);
    });

    group('isDueOnDay', () {
      test('daily habit is due every day', () {
        final habit = Habit(name: 'Daily', frequency: HabitFrequency.daily);

        // Monday through Sunday
        for (int i = 0; i < 7; i++) {
          final date = DateTime(2026, 2, 16 + i); // 2026-02-16 is Monday
          expect(habit.isDueOnDay(date), true,
              reason: 'Should be due on weekday ${date.weekday}');
        }
      });

      test('weekday habit is due Mon-Fri only', () {
        final habit = Habit(name: 'Work', frequency: HabitFrequency.weekdays);

        // Monday=2026-02-16 through Friday=2026-02-20
        for (int i = 0; i < 5; i++) {
          final date = DateTime(2026, 2, 16 + i);
          expect(habit.isDueOnDay(date), true,
              reason: 'Should be due on weekday ${date.weekday}');
        }
        // Saturday=2026-02-21 and Sunday=2026-02-22
        expect(habit.isDueOnDay(DateTime(2026, 2, 21)), false);
        expect(habit.isDueOnDay(DateTime(2026, 2, 22)), false);
      });

      test('weekend habit is due Sat-Sun only', () {
        final habit =
            Habit(name: 'Weekend', frequency: HabitFrequency.weekends);

        // Monday-Friday
        for (int i = 0; i < 5; i++) {
          final date = DateTime(2026, 2, 16 + i);
          expect(habit.isDueOnDay(date), false);
        }
        // Saturday and Sunday
        expect(habit.isDueOnDay(DateTime(2026, 2, 21)), true);
        expect(habit.isDueOnDay(DateTime(2026, 2, 22)), true);
      });

      test('specificDays habit is due on selected days only', () {
        final habit = Habit(
          name: 'MWF',
          frequency: HabitFrequency.specificDays,
          specificDays: [1, 3, 5], // Mon, Wed, Fri
        );

        expect(habit.isDueOnDay(DateTime(2026, 2, 16)), true); // Monday
        expect(habit.isDueOnDay(DateTime(2026, 2, 17)), false); // Tuesday
        expect(habit.isDueOnDay(DateTime(2026, 2, 18)), true); // Wednesday
        expect(habit.isDueOnDay(DateTime(2026, 2, 19)), false); // Thursday
        expect(habit.isDueOnDay(DateTime(2026, 2, 20)), true); // Friday
      });

      test('timesPerWeek habit is always due', () {
        final habit = Habit(
          name: '3x week',
          frequency: HabitFrequency.timesPerWeek,
          timesPerWeek: 3,
        );

        for (int i = 0; i < 7; i++) {
          final date = DateTime(2026, 2, 16 + i);
          expect(habit.isDueOnDay(date), true);
        }
      });
    });
  });

  group('HabitFrequency', () {
    test('has correct values', () {
      expect(HabitFrequency.values.length, 5);
      expect(HabitFrequency.daily.index, 0);
      expect(HabitFrequency.weekdays.index, 1);
      expect(HabitFrequency.weekends.index, 2);
      expect(HabitFrequency.specificDays.index, 3);
      expect(HabitFrequency.timesPerWeek.index, 4);
    });
  });
}
