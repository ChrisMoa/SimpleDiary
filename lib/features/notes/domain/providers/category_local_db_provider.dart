import 'package:day_tracker/core/database/abstract_local_db_provider_state.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/data/repositories/category_local_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryLocalDataProvider
    extends AbstractLocalDbProviderState<NoteCategory> {
  CategoryLocalDataProvider()
      : super(tableName: 'categories', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return CategoryLocalDbHelper(
      tableName: tableName,
      primaryKey: primaryKey,
      dbFile: dbFile,
    );
  }

  /// Override to automatically add defaults for new/empty databases
  @override
  Future<void> readObjectsFromDatabase() async {
    await super.readObjectsFromDatabase();

    // If no categories exist, add the default ones
    // This ensures defaults are added for new users and on first run
    if (state.isEmpty) {
      LogWrapper.logger.i('No categories found, initializing with defaults');
      await _addDefaultCategories();
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
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

    for (final category in defaultCategories) {
      await addElement(category);
    }
    LogWrapper.logger.i('Added ${defaultCategories.length} default categories');
  }

  /// Check if a category name already exists (for validation)
  bool categoryNameExists(String name, {String? excludeId}) {
    return state.any(
      (category) =>
          category.title.toLowerCase() == name.toLowerCase() &&
          category.id != excludeId,
    );
  }

  /// Get a category by ID
  NoteCategory? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if any notes use this category (to be implemented when integrating with notes)
  Future<bool> isCategoryInUse(String categoryId) async {
    // TODO: This will need to check the notes database
    // For now, return false to allow deletion
    return false;
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final categoryLocalDataProvider =
    StateNotifierProvider<CategoryLocalDataProvider, List<NoteCategory>>((ref) {
  return CategoryLocalDataProvider();
});

//-----------------------------------------------------------------------------------------------------------------------------------

/// Provider to get the first category (default category for new notes)
final defaultCategoryProvider = Provider<NoteCategory?>((ref) {
  final categories = ref.watch(categoryLocalDataProvider);
  return categories.isNotEmpty ? categories.first : null;
});
