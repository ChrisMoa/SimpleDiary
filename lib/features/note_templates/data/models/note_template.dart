import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

class NoteTemplate implements LocalDbElement {
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

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return NoteTemplate.fromMap({
      ...map,
      'descriptionSections': map.containsKey('descriptionSections') ? map['descriptionSections'] : '',
    });
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
