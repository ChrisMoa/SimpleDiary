import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';

enum NoteCategories {
  arbeit,
  freizeit,
  essen,
  gym,
  schlafen,
}

class NoteCategory extends DbEntity {
  NoteCategory({required this.title, required this.color, id})
      : id = id ?? Utils.uuid.v4();

  /// Creates a NoteCategory from a title string.
  /// Falls back to a default color if the title is not found in the hardcoded list.
  factory NoteCategory.fromString(String title) {
    final cats =
        availableNoteCategories.where((element) => element.title == title);
    if (cats.isNotEmpty) {
      return cats.first;
    }
    return NoteCategory(title: title, color: Colors.blue);
  }

  final String title;
  final Color color;
  final String id;

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'categories';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('title'),
    DbColumn.integer('colorValue'),
  ];

  static const List<DbMigration> migrations = [];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'title': title,
        'colorValue': color.toARGB32(),
      };

  static NoteCategory fromDbMap(Map<String, dynamic> map) => NoteCategory(
        id: map['id'] as String,
        title: map['title'] as String,
        color: Color(map['colorValue'] as int),
      );

  @override
  String get primaryKeyValue => id;

  // ── Domain helpers ─────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteCategory && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  NoteCategory copyWith({
    String? id,
    String? title,
    Color? color,
  }) {
    return NoteCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }
}

final availableNoteCategories = [
  NoteCategory(
    title: 'Work',
    color: Colors.purple,
  ),
  NoteCategory(
    title: 'Leisure',
    color: Colors.lightBlue,
  ),
  NoteCategory(
    title: 'Food',
    color: Colors.amber,
  ),
  NoteCategory(
    title: 'Gym',
    color: Colors.green,
  ),
  NoteCategory(
    title: 'Sleep',
    color: Colors.grey,
  ),
];
