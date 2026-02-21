import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:uuid/uuid.dart';

enum GoalTimeframe { weekly, monthly }

enum GoalStatus { active, completed, failed, archived }

class Goal extends DbEntity {
  final String id;
  final DayRatings category;
  final double targetValue;
  final GoalTimeframe timeframe;
  final DateTime startDate;
  final DateTime endDate;
  GoalStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  Goal({
    String? id,
    required this.category,
    required this.targetValue,
    required this.timeframe,
    required this.startDate,
    required this.endDate,
    this.status = GoalStatus.active,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'goals';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.integer('category'),
    DbColumn.real('targetValue'),
    DbColumn.integer('timeframe'),
    DbColumn.text('startDate'),
    DbColumn.text('endDate'),
    DbColumn.integer('status'),
    DbColumn.text('createdAt'),
    DbColumn.text('completedAt', isNotNull: false),
  ];

  static const List<DbMigration> migrations = [];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'category': category.index,
        'targetValue': targetValue,
        'timeframe': timeframe.index,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  static Goal fromDbMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        category: DayRatings.values[map['category'] as int],
        targetValue: (map['targetValue'] as num).toDouble(),
        timeframe: GoalTimeframe.values[map['timeframe'] as int],
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        status: GoalStatus.values[map['status'] as int],
        createdAt: DateTime.parse(map['createdAt'] as String),
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
      );

  @override
  String get primaryKeyValue => id;

  // ── Domain helpers ─────────────────────────────────────────────

  /// Factory for creating a weekly goal
  factory Goal.weekly({
    required DayRatings category,
    required double targetValue,
    DateTime? startDate,
  }) {
    final start = startDate ?? _getWeekStart(DateTime.now());
    return Goal(
      category: category,
      targetValue: targetValue,
      timeframe: GoalTimeframe.weekly,
      startDate: start,
      endDate: start.add(const Duration(days: 6)),
    );
  }

  /// Factory for creating a monthly goal
  factory Goal.monthly({
    required DayRatings category,
    required double targetValue,
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    final end = DateTime(start.year, start.month + 1, 0); // Last day of month
    return Goal(
      category: category,
      targetValue: targetValue,
      timeframe: GoalTimeframe.monthly,
      startDate: start,
      endDate: end,
    );
  }

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return totalDays;
    return now.difference(startDate).inDays + 1;
  }

  double get timeProgress {
    return daysElapsed / totalDays;
  }

  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1))) &&
        status == GoalStatus.active;
  }

  bool get hasEnded {
    return DateTime.now().isAfter(endDate);
  }

  Goal copyWith({
    GoalStatus? status,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id,
      category: category,
      targetValue: targetValue,
      timeframe: timeframe,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
