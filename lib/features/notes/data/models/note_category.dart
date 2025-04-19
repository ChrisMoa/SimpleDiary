import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';

enum NoteCategories {
  arbeit,
  freizeit,
  essen,
  gym,
  schlafen,
}

class NoteCategory {
  NoteCategory({required this.title, required this.color, id})
      : id = id ?? Utils.uuid.v4();
  factory NoteCategory.fromString(String title) {
    final _cats =
        availableNoteCategories.where((element) => element.title == title);
    assert(_cats.length == 1,
        '$title not found in the category list or too many results');
    return _cats.first;
  }

  final String title;
  final Color color;
  final String? id;
}

final availableNoteCategories = [
  NoteCategory(
    title: 'Arbeit',
    color: Colors.purple,
  ),
  NoteCategory(
    title: 'Freizeit',
    color: Colors.lightBlue,
  ),
  NoteCategory(
    title: 'Essen',
    color: Colors.amber,
  ),
  NoteCategory(
    title: 'Gym',
    color: Colors.green,
  ),
  NoteCategory(
    title: 'Schlafen',
    color: Colors.grey,
  ),
];
