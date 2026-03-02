import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/utils/utils.dart';

class NoteAttachment extends DbEntity {
  String id;
  String noteId;
  String filePath;
  DateTime createdAt;
  int fileSize;
  String? remoteUrl;

  NoteAttachment({
    required this.noteId,
    required this.filePath,
    required this.createdAt,
    required this.fileSize,
    this.remoteUrl,
    String? id,
  }) : id = id ?? Utils.uuid.v4();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'note_attachments';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('noteId'),
    DbColumn.text('filePath'),
    DbColumn.text('createdAt'),
    DbColumn.integer('fileSize', defaultValue: '0'),
    DbColumn.text('remoteUrl', isNotNull: false),
  ];

  static final List<DbMigration> migrations = [
    DbMigration.addColumn(
      version: 1,
      columnName: 'remoteUrl',
      columnDefinition: 'TEXT',
      description: 'Supabase Storage URL for synced attachments',
    ),
  ];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'noteId': noteId,
        'filePath': filePath,
        'createdAt': Utils.toDateTime(createdAt),
        'fileSize': fileSize,
        'remoteUrl': remoteUrl,
      };

  static NoteAttachment fromDbMap(Map<String, dynamic> map) => NoteAttachment(
        id: map['id'],
        noteId: map['noteId'],
        filePath: map['filePath'],
        createdAt: Utils.fromDateTimeString(map['createdAt']),
        fileSize: map['fileSize'] ?? 0,
        remoteUrl: map['remoteUrl'],
      );

  @override
  String get primaryKeyValue => id;

  // ── JSON export/import ─────────────────────────────────────────

  Map<String, dynamic> toMap() => toDbMap();

  factory NoteAttachment.fromMap(Map<String, dynamic> map) => fromDbMap(map);

  String toJson() => json.encode(toMap());

  factory NoteAttachment.fromJson(String source) =>
      NoteAttachment.fromMap(json.decode(source));

  // ── Domain helpers ─────────────────────────────────────────────

  NoteAttachment copyWith({
    String? id,
    String? noteId,
    String? filePath,
    DateTime? createdAt,
    int? fileSize,
    String? remoteUrl,
  }) {
    return NoteAttachment(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }
}
