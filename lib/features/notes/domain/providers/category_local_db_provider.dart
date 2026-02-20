import 'package:day_tracker/core/database/db_repository.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CategoryLocalDataProvider — subclasses DbRepository for custom logic
/// (default category initialization, name validation).
class CategoryLocalDataProvider extends DbRepository<NoteCategory> {
  CategoryLocalDataProvider()
      : super(
          tableName: NoteCategory.tableName,
          columns: NoteCategory.columns,
          fromMap: NoteCategory.fromDbMap,
          migrations: NoteCategory.migrations,
        );

  /// Override to automatically add defaults for new/empty databases
  @override
  Future<void> readObjectsFromDatabase() async {
    await super.readObjectsFromDatabase();

    if (state.isEmpty) {
      LogWrapper.logger.i('No categories found, initializing with defaults');
      await _addDefaultCategories();
    }
  }

  Future<void> _addDefaultCategories() async {
    final languageCode = settingsContainer.activeUserSettings.languageCode;
    final categoryNames = _getLocalizedCategoryNames(languageCode);

    final defaultCategories = [
      NoteCategory(
        title: categoryNames['work']!,
        color: Colors.purple,
      ),
      NoteCategory(
        title: categoryNames['leisure']!,
        color: Colors.lightBlue,
      ),
      NoteCategory(
        title: categoryNames['food']!,
        color: Colors.amber,
      ),
      NoteCategory(
        title: categoryNames['gym']!,
        color: Colors.green,
      ),
      NoteCategory(
        title: categoryNames['sleep']!,
        color: Colors.grey,
      ),
    ];

    for (final category in defaultCategories) {
      await addElement(category);
    }
    LogWrapper.logger.i('Added ${defaultCategories.length} default categories in language: $languageCode');
  }

  Map<String, String> _getLocalizedCategoryNames(String languageCode) {
    switch (languageCode) {
      case 'de':
        return {
          'work': 'Arbeit',
          'leisure': 'Freizeit',
          'food': 'Essen',
          'gym': 'Gym',
          'sleep': 'Schlafen',
        };
      case 'es':
        return {
          'work': 'Trabajo',
          'leisure': 'Ocio',
          'food': 'Comida',
          'gym': 'Gimnasio',
          'sleep': 'Dormir',
        };
      case 'fr':
        return {
          'work': 'Travail',
          'leisure': 'Loisirs',
          'food': 'Nourriture',
          'gym': 'Gym',
          'sleep': 'Sommeil',
        };
      case 'en':
      default:
        return {
          'work': 'Work',
          'leisure': 'Leisure',
          'food': 'Food',
          'gym': 'Gym',
          'sleep': 'Sleep',
        };
    }
  }

  bool categoryNameExists(String name, {String? excludeId}) {
    return state.any(
      (category) =>
          category.title.toLowerCase() == name.toLowerCase() &&
          category.id != excludeId,
    );
  }

  NoteCategory? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isCategoryInUse(String categoryId) async {
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
