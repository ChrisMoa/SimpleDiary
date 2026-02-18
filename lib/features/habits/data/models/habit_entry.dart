import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:uuid/uuid.dart';

class HabitEntry implements LocalDbElement {
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

  /// Normalized date key (yyyy-MM-dd) for grouping
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  String getId() => id;

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) {
    final entry = element as HabitEntry;
    return {
      'id': entry.id,
      'habitId': entry.habitId,
      'date': entry.date.toIso8601String(),
      'isCompleted': entry.isCompleted ? 1 : 0,
      'count': entry.count,
      'note': entry.note,
    };
  }

  @override
  HabitEntry fromLocalDbMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
      count: map['count'] as int? ?? 0,
      note: map['note'] as String? ?? '',
    );
  }

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
