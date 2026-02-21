// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final emptyNote = Note(
  description: 'Only a test description',
  from: DateTime.now(),
  title: 'TestTitle',
  to: DateTime.now().add(
    const Duration(hours: 1),
  ),
  isAllDay: false,
  noteCategory: availableNoteCategories.first,
  isFavorite: false,
);

class Note extends DbEntity {
  String? id;
  String title;
  String description;
  DateTime from;
  DateTime to;
  bool isAllDay;
  NoteCategory noteCategory;
  bool isFavorite;

  Note({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    required this.noteCategory,
    this.isAllDay = false,
    this.isFavorite = false,
    id,
  }) : id = id ?? Utils.uuid.v4();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'notes';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('title'),
    DbColumn.text('description'),
    DbColumn.text('fromDate'),
    DbColumn.text('toDate'),
    DbColumn.integer('isAllDay'),
    DbColumn.text('noteCategory'),
    DbColumn.integer('isFavorite', defaultValue: '0'),
  ];

  static final List<DbMigration> migrations = [
    DbMigration.addColumn(
      version: 1,
      columnName: 'isFavorite',
      columnDefinition: 'INTEGER NOT NULL DEFAULT 0',
    ),
  ];

  // ── SQLite serialization (single source of truth) ──────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'title': title,
        'description': description,
        'fromDate': Utils.toDateTime(from),
        'toDate': Utils.toDateTime(to),
        'isAllDay': isAllDay ? 1 : 0,
        'noteCategory': noteCategory.title,
        'isFavorite': isFavorite ? 1 : 0,
      };

  static Note fromDbMap(Map<String, dynamic> map) => Note(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        from: Utils.fromDateTimeString(map['fromDate']),
        to: Utils.fromDateTimeString(map['toDate']),
        isAllDay: map['isAllDay'] == 0 ? false : true,
        noteCategory: NoteCategory.fromString(map['noteCategory']),
        isFavorite: (map['isFavorite'] ?? 0) == 1,
      );

  @override
  String get primaryKeyValue => id!;

  // ── JSON export/import serialization (different format) ────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'from': Utils.toDateTime(from),
      'to': Utils.toDateTime(to),
      'isAllDay': isAllDay,
      'noteCategory': noteCategory.title,
      'isFavorite': isFavorite,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      from: Utils.fromDateTimeString(map['from']),
      to: Utils.fromDateTimeString(map['to']),
      isAllDay: map['isAllDay'],
      noteCategory: NoteCategory.fromString(map['noteCategory']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromEmpty() {
    return Note(
      id: Utils.uuid.v4(),
      title: '',
      description: '',
      from: DateTime.now(),
      to: DateTime.now().add(const Duration(minutes: 15)),
      isAllDay: false,
      noteCategory: availableNoteCategories.first,
      isFavorite: false,
    );
  }

  // ── Domain helpers ─────────────────────────────────────────────

  Note copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? from,
    DateTime? to,
    bool? isAllDay,
    NoteCategory? noteCategory,
    bool? isFavorite,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      from: from ?? this.from,
      to: to ?? this.to,
      isAllDay: isAllDay ?? this.isAllDay,
      noteCategory: noteCategory ?? this.noteCategory,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Appointment convertToCalendarAppointment() {
    return Appointment(
      startTime: from,
      endTime: to,
      subject: title,
      notes: description,
      isAllDay: isAllDay,
      color: noteCategory.color,
      id: id,
    );
  }
}
