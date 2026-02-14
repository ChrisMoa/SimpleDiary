import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';

enum NoteCategories {
  arbeit,
  freizeit,
  essen,
  gym,
  schlafen,
}

class NoteCategory implements LocalDbElement {
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
    // Category not in hardcoded list (user-created category) - use placeholder color
    // The actual color will be resolved from the categories provider
    return NoteCategory(title: title, color: Colors.blue);
  }

  final String title;
  final Color color;
  final String id;

  /// Equality based on title, since notes reference categories by title
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

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return NoteCategory(
      id: map['id'] as String,
      title: map['title'] as String,
      color: Color(map['colorValue'] as int),
    );
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) {
    final category = element as NoteCategory;
    return {
      'id': category.id,
      'title': category.title,
      'colorValue': category.color.toARGB32(),
    };
  }

  @override
  getId() {
    return id;
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
