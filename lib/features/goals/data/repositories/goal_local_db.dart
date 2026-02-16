import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';

class GoalLocalDbHelper extends LocalDbHelper {
  GoalLocalDbHelper(
      {required super.tableName, required super.primaryKey, required super.dbFile});

  @override
  Future<void> onCreateSqlTable() async {
    await database!.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        category INTEGER NOT NULL,
        targetValue REAL NOT NULL,
        timeframe INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        status INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return Goal(
      id: elementMap['id'] as String,
      category: DayRatings.values[elementMap['category'] as int],
      targetValue: (elementMap['targetValue'] as num).toDouble(),
      timeframe: GoalTimeframe.values[elementMap['timeframe'] as int],
      startDate: DateTime.parse(elementMap['startDate'] as String),
      endDate: DateTime.parse(elementMap['endDate'] as String),
      status: GoalStatus.values[elementMap['status'] as int],
      createdAt: DateTime.parse(elementMap['createdAt'] as String),
      completedAt: elementMap['completedAt'] != null
          ? DateTime.parse(elementMap['completedAt'] as String)
          : null,
    );
  }

  /// Get all active goals
  Future<List<Goal>> getActiveGoals() async {
    final records = await database!.query(
      tableName,
      where: 'status = ?',
      whereArgs: [GoalStatus.active.index],
    );
    return records.map((r) => generateElementFromDbMap(r) as Goal).toList();
  }

  /// Get goals for a specific category
  Future<List<Goal>> getGoalsForCategory(DayRatings category) async {
    final records = await database!.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'createdAt DESC',
    );
    return records.map((r) => generateElementFromDbMap(r) as Goal).toList();
  }

  /// Get completed goals count for streak calculation
  Future<int> getCompletedGoalsCount() async {
    final result = await database!.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE status = ?',
      [GoalStatus.completed.index],
    );
    return result.first['count'] as int;
  }
}
