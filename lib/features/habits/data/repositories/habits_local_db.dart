import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';

class HabitsLocalDbHelper extends LocalDbHelper {
  HabitsLocalDbHelper({
    required super.tableName,
    required super.primaryKey,
    required super.dbFile,
  });

  @override
  Future<void> onCreateSqlTable() async {
    await database!.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        iconCodePoint INTEGER NOT NULL DEFAULT 57686,
        colorValue INTEGER NOT NULL DEFAULT 4283215696,
        frequency INTEGER NOT NULL DEFAULT 0,
        targetCount INTEGER NOT NULL DEFAULT 1,
        specificDays TEXT NOT NULL DEFAULT '[]',
        timesPerWeek INTEGER NOT NULL DEFAULT 3,
        createdAt TEXT NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return Habit(
      id: elementMap['id'] as String,
      name: elementMap['name'] as String,
      description: elementMap['description'] as String? ?? '',
      iconCodePoint: elementMap['iconCodePoint'] as int? ?? 0xe156,
      colorValue: elementMap['colorValue'] as int? ?? 0xFF4CAF50,
      frequency: HabitFrequency.values[elementMap['frequency'] as int],
      targetCount: elementMap['targetCount'] as int? ?? 1,
      specificDays: elementMap['specificDays'] != null
          ? List<int>.from(jsonDecode(elementMap['specificDays'] as String))
          : [],
      timesPerWeek: elementMap['timesPerWeek'] as int? ?? 3,
      createdAt: DateTime.parse(elementMap['createdAt'] as String),
      isArchived: (elementMap['isArchived'] as int? ?? 0) == 1,
    );
  }
}
