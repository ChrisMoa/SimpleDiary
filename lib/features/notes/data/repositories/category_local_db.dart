import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';

class CategoryLocalDbHelper extends LocalDbHelper {
  CategoryLocalDbHelper({
    required super.tableName,
    required super.primaryKey,
    required super.dbFile,
  });

  @override
  Future<void> onCreateSqlTable() async {
    //* create categories table
    await database!.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            $primaryKey TEXT PRIMARY KEY,
            title TEXT NOT NULL UNIQUE,
            colorValue INTEGER NOT NULL
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return NoteCategory(
      id: '',
      title: '',
      color: const Color(0xFF000000),
    ).fromLocalDbMap(elementMap);
  }
}
