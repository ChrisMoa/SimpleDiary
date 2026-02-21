import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

class NoteTemplate extends DbEntity {
  String? id;
  String title;
  String description;
  int durationMinutes;
  NoteCategory noteCategory;
  List<DescriptionSection> descriptionSections;

  NoteTemplate({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.noteCategory,
    this.descriptionSections = const [],
    String? id,
  }) : id = id ?? Utils.uuid.v4();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'note_templates';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('title'),
    DbColumn.text('description'),
    DbColumn.integer('durationMinutes'),
    DbColumn.text('noteCategory'),
    DbColumn.text('descriptionSections', defaultValue: "''"),
  ];

  static final List<DbMigration> migrations = [
    DbMigration.addColumn(
      version: 1,
      columnName: 'descriptionSections',
      columnDefinition: "TEXT NOT NULL DEFAULT ''",
    ),
  ];

  // ── Serialization (single source of truth for SQLite & JSON) ───

  @override
  Map<String, dynamic> toDbMap() => toMap();

  static NoteTemplate fromDbMap(Map<String, dynamic> map) =>
      NoteTemplate.fromMap({
        ...map,
        'descriptionSections':
            map.containsKey('descriptionSections') ? map['descriptionSections'] : '',
      });

  @override
  String get primaryKeyValue => id!;

  // ── JSON export/import ─────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'noteCategory': noteCategory.title,
      'descriptionSections': DescriptionSection.encode(descriptionSections),
    };
  }

  factory NoteTemplate.fromMap(Map<String, dynamic> map) {
    return NoteTemplate(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      durationMinutes: map['durationMinutes'],
      noteCategory: NoteCategory.fromString(map['noteCategory']),
      descriptionSections: map['descriptionSections'] != null
          ? DescriptionSection.decode(map['descriptionSections'] as String)
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteTemplate.fromEmpty() {
    return NoteTemplate(
      id: Utils.uuid.v4(),
      title: '',
      description: '',
      durationMinutes: 30,
      noteCategory: availableNoteCategories.first,
      descriptionSections: [],
    );
  }

  // ── Domain helpers ─────────────────────────────────────────────

  bool get hasDescriptionSections => descriptionSections.isNotEmpty;

  String generateDescription() {
    if (descriptionSections.isEmpty) return description;
    return descriptionSections
        .map((section) => '${section.title}:\n')
        .join('\n');
  }

  NoteTemplate copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    NoteCategory? noteCategory,
    List<DescriptionSection>? descriptionSections,
  }) {
    return NoteTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      noteCategory: noteCategory ?? this.noteCategory,
      descriptionSections: descriptionSections ?? this.descriptionSections,
    );
  }
}
