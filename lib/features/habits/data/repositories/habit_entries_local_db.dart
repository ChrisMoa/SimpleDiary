import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';

class HabitEntriesLocalDbHelper extends LocalDbHelper {
  HabitEntriesLocalDbHelper({
    required super.tableName,
    required super.primaryKey,
    required super.dbFile,
  });

  @override
  Future<void> onCreateSqlTable() async {
    await database!.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        count INTEGER NOT NULL DEFAULT 0,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');
    // Index for fast lookups by habitId and date
    await database!.execute('''
      CREATE INDEX IF NOT EXISTS idx_habit_entries_habit_date
      ON $tableName (habitId, date)
    ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return HabitEntry(
      id: elementMap['id'] as String,
      habitId: elementMap['habitId'] as String,
      date: DateTime.parse(elementMap['date'] as String),
      isCompleted: (elementMap['isCompleted'] as int) == 1,
      count: elementMap['count'] as int? ?? 0,
      note: elementMap['note'] as String? ?? '',
    );
  }
}
