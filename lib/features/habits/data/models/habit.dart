import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit extends DbEntity {
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

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'habits';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('name'),
    DbColumn.text('description', defaultValue: "''"),
    DbColumn.integer('iconCodePoint', defaultValue: '57686'),
    DbColumn.integer('colorValue', defaultValue: '4283215696'),
    DbColumn.integer('frequency', defaultValue: '0'),
    DbColumn.integer('targetCount', defaultValue: '1'),
    DbColumn.text('specificDays', defaultValue: "'[]'"),
    DbColumn.integer('timesPerWeek', defaultValue: '3'),
    DbColumn.text('createdAt'),
    DbColumn.integer('isArchived', defaultValue: '0'),
  ];

  static const List<DbMigration> migrations = [];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'description': description,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'frequency': frequency.index,
        'targetCount': targetCount,
        'specificDays': jsonEncode(specificDays),
        'timesPerWeek': timesPerWeek,
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived ? 1 : 0,
      };

  static Habit fromDbMap(Map<String, dynamic> map) => Habit(
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

  @override
  String get primaryKeyValue => id;

  // ── Domain helpers ─────────────────────────────────────────────

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
