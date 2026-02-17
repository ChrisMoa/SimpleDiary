import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';

class NoteAttachment implements LocalDbElement {
  String id;
  String noteId;
  String filePath;
  DateTime createdAt;
  int fileSize;

  NoteAttachment({
    required this.noteId,
    required this.filePath,
    required this.createdAt,
    required this.fileSize,
    String? id,
  }) : id = id ?? Utils.uuid.v4();

  NoteAttachment copyWith({
    String? id,
    String? noteId,
    String? filePath,
    DateTime? createdAt,
    int? fileSize,
  }) {
    return NoteAttachment(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noteId': noteId,
      'filePath': filePath,
      'createdAt': Utils.toDateTime(createdAt),
      'fileSize': fileSize,
    };
  }

  factory NoteAttachment.fromMap(Map<String, dynamic> map) {
    return NoteAttachment(
      id: map['id'],
      noteId: map['noteId'],
      filePath: map['filePath'],
      createdAt: Utils.fromDateTimeString(map['createdAt']),
      fileSize: map['fileSize'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteAttachment.fromJson(String source) =>
      NoteAttachment.fromMap(json.decode(source));

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return NoteAttachment(
      id: map['id'],
      noteId: map['noteId'],
      filePath: map['filePath'],
      createdAt: Utils.fromDateTimeString(map['createdAt']),
      fileSize: map['fileSize'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement map) {
    return {
      'id': id,
      'noteId': noteId,
      'filePath': filePath,
      'createdAt': Utils.toDateTime(createdAt),
      'fileSize': fileSize,
    };
  }

  @override
  getId() => id;
}
