import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:uuid/uuid.dart';

class HabitEntry extends DbEntity {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final int count;
  final String note;

  HabitEntry({
    String? id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.count = 0,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'habit_entries';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('habitId'),
    DbColumn.text('date'),
    DbColumn.integer('isCompleted', defaultValue: '0'),
    DbColumn.integer('count', defaultValue: '0'),
    DbColumn.text('note', isNotNull: false, defaultValue: "''"),
  ];

  static const List<DbMigration> migrations = [];

  static const List<String> additionalSql = [
    'CREATE INDEX IF NOT EXISTS idx_habit_entries_habit_date '
        'ON $tableName (habitId, date)',
  ];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'habitId': habitId,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted ? 1 : 0,
        'count': count,
        'note': note,
      };

  static HabitEntry fromDbMap(Map<String, dynamic> map) => HabitEntry(
        id: map['id'] as String,
        habitId: map['habitId'] as String,
        date: DateTime.parse(map['date'] as String),
        isCompleted: (map['isCompleted'] as int) == 1,
        count: map['count'] as int? ?? 0,
        note: map['note'] as String? ?? '',
      );

  @override
  String get primaryKeyValue => id;

  // ── LocalDbElement backward compat ─────────────────────────────

  @override
  HabitEntry fromLocalDbMap(Map<String, dynamic> map) => fromDbMap(map);

  // ── Domain helpers ─────────────────────────────────────────────

  /// Normalized date key (yyyy-MM-dd) for grouping
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  HabitEntry copyWith({
    bool? isCompleted,
    int? count,
    String? note,
  }) {
    return HabitEntry(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted ?? this.isCompleted,
      count: count ?? this.count,
      note: note ?? this.note,
    );
  }
}
