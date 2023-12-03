// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/database/remote_db_element.dart';
import 'package:SimpleDiary/model/notes/note_category.dart';
import 'package:SimpleDiary/utils.dart';

final emptyNote = Note(
  description: 'Only a test description',
  from: DateTime.now(),
  title: 'TestTitle',
  to: DateTime.now().add(
    const Duration(hours: 1),
  ),
  isAllDay: false,
  noteCategory: availableNoteCategories.first,
);

class Note implements LocalDbElement, RemoteDbElement {
  String? id;
  String title;
  String description;
  DateTime from;
  DateTime to;
  bool isAllDay;
  NoteCategory noteCategory;

  Note({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    required this.noteCategory,
    this.isAllDay = false,
    id,
  }) : id = id ?? Utils.uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'from': Utils.toDateTime(from),
      'to': Utils.toDateTime(to),
      'isAllDay': isAllDay,
      'noteCategory': noteCategory.title,
    };
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
    );
  }

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      from: Utils.fromDateTimeString(map['fromDate']),
      to: Utils.fromDateTimeString(map['toDate']),
      isAllDay: map['isAllDay'] == 0 ? false : true,
      noteCategory: NoteCategory.fromString(map['noteCategory']),
    );
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement map) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fromDate': Utils.toDateTime(from),
      'toDate': Utils.toDateTime(to),
      // has to be stored as an integer as dart has no int bool conversion
      'isAllDay': isAllDay ? 1 : 0,
      'noteCategory': noteCategory.title,
    };
  }

  @override
  getId() {
    return id;
  }

  @override
  RemoteDbElement fromRemoteDbMap(Map<String, dynamic> map) {
    return Note(
      id: map['id']['stringValue'],
      title: map['title']['stringValue'],
      description: map['description']['stringValue'],
      from: Utils.fromDateTimeString(map['from']['stringValue']),
      to: Utils.fromDateTimeString(map['to']['stringValue']),
      isAllDay: map['isAllDay']['booleanValue'] ?? false,
      noteCategory: NoteCategory.fromString(map['noteCategory']['stringValue']),
    );
  }

  @override
  Map<String, dynamic> toRemoteDbMap() {
    return {
      'fields': {
        'id': {'stringValue': id},
        'title': {'stringValue': title},
        'description': {'stringValue': description},
        'from': {'stringValue': Utils.toDateTime(from)},
        'to': {'stringValue': Utils.toDateTime(to)},
        'noteCategory': {'stringValue': noteCategory.title},
        'isAllDay': {'booleanValue': isAllDay},
      },
    };
  }
}
