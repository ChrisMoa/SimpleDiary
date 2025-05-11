import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

class NoteTemplate implements LocalDbElement {
  String? id;
  String title;
  String description;
  int durationMinutes;
  NoteCategory noteCategory;

  NoteTemplate({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.noteCategory,
    String? id,
  }) : id = id ?? Utils.uuid.v4();

  NoteTemplate copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    NoteCategory? noteCategory,
  }) {
    return NoteTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      noteCategory: noteCategory ?? this.noteCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'noteCategory': noteCategory.title,
    };
  }

  factory NoteTemplate.fromMap(Map<String, dynamic> map) {
    return NoteTemplate(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      durationMinutes: map['durationMinutes'],
      noteCategory: NoteCategory.fromString(map['noteCategory']),
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
    );
  }

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return NoteTemplate.fromMap(map);
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement map) {
    final templateMap = map as NoteTemplate;
    return templateMap.toMap();
  }

  @override
  getId() {
    return id;
  }
}
