import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:uuid/uuid.dart';

enum GoalTimeframe { weekly, monthly }

enum GoalStatus { active, completed, failed, archived }

class Goal implements LocalDbElement {
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

  /// Days remaining until goal deadline
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  /// Total days in goal period
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Days elapsed in goal period
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return totalDays;
    return now.difference(startDate).inDays + 1;
  }

  /// Progress through time period (0.0 to 1.0)
  double get timeProgress {
    return daysElapsed / totalDays;
  }

  /// Whether the goal period is currently active
  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1))) &&
        status == GoalStatus.active;
  }

  /// Whether the goal period has ended
  bool get hasEnded {
    return DateTime.now().isAfter(endDate);
  }

  @override
  String getId() => id;

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) {
    final goal = element as Goal;
    return {
      'id': goal.id,
      'category': goal.category.index,
      'targetValue': goal.targetValue,
      'timeframe': goal.timeframe.index,
      'startDate': goal.startDate.toIso8601String(),
      'endDate': goal.endDate.toIso8601String(),
      'status': goal.status.index,
      'createdAt': goal.createdAt.toIso8601String(),
      'completedAt': goal.completedAt?.toIso8601String(),
    };
  }

  @override
  Goal fromLocalDbMap(Map<String, dynamic> map) {
    return Goal(
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
