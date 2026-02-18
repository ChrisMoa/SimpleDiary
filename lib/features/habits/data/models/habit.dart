import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit implements LocalDbElement {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final int colorValue;
  final HabitFrequency frequency;
  final int targetCount;
  final List<int> specificDays; // 1=Mon, 7=Sun (ISO weekday)
  final int timesPerWeek;
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    String? id,
    required this.name,
    this.description = '',
    this.iconCodePoint = 0xe156, // Icons.check_circle_outline
    this.colorValue = 0xFF4CAF50, // Colors.green
    this.frequency = HabitFrequency.daily,
    this.targetCount = 1,
    this.specificDays = const [],
    this.timesPerWeek = 3,
    DateTime? createdAt,
    this.isArchived = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  bool isDueOnDay(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;
      case HabitFrequency.weekends:
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      case HabitFrequency.specificDays:
        return specificDays.contains(date.weekday);
      case HabitFrequency.timesPerWeek:
        // Always due - the user decides which days
        return true;
    }
  }

  @override
  String getId() => id;

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) {
    final habit = element as Habit;
    return {
      'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'iconCodePoint': habit.iconCodePoint,
      'colorValue': habit.colorValue,
      'frequency': habit.frequency.index,
      'targetCount': habit.targetCount,
      'specificDays': jsonEncode(habit.specificDays),
      'timesPerWeek': habit.timesPerWeek,
      'createdAt': habit.createdAt.toIso8601String(),
      'isArchived': habit.isArchived ? 1 : 0,
    };
  }

  @override
  Habit fromLocalDbMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      iconCodePoint: map['iconCodePoint'] as int? ?? 0xe156,
      colorValue: map['colorValue'] as int? ?? 0xFF4CAF50,
      frequency: HabitFrequency.values[map['frequency'] as int],
      targetCount: map['targetCount'] as int? ?? 1,
      specificDays: map['specificDays'] != null
          ? List<int>.from(jsonDecode(map['specificDays'] as String))
          : [],
      timesPerWeek: map['timesPerWeek'] as int? ?? 3,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as int? ?? 0) == 1,
    );
  }

  Habit copyWith({
    String? name,
    String? description,
    int? iconCodePoint,
    int? colorValue,
    HabitFrequency? frequency,
    int? targetCount,
    List<int>? specificDays,
    int? timesPerWeek,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      specificDays: specificDays ?? this.specificDays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
