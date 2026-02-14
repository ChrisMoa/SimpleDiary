// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
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

class Note implements LocalDbElement {
  String? id;
  String title;
  String description;
  DateTime from;
  DateTime to;
  bool isAllDay;
  NoteCategory noteCategory;
  bool isFavorite; //! mark this note as favorite

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
      isFavorite: (map['isFavorite'] ?? 0) == 1,
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
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  @override
  getId() {
    return id;
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
