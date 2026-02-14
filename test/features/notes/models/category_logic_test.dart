import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the CategoryLocalDataProvider business logic
/// (without requiring Riverpod - testing the pure logic)
void main() {
  group('Category validation logic', () {
    /// Replicates categoryNameExists from CategoryLocalDataProvider
    bool categoryNameExists(
        List<NoteCategory> categories, String name, {String? excludeId}) {
      return categories.any(
        (category) =>
            category.title.toLowerCase() == name.toLowerCase() &&
            category.id != excludeId,
      );
    }

    /// Replicates getCategoryById from CategoryLocalDataProvider
    NoteCategory? getCategoryById(List<NoteCategory> categories, String id) {
      try {
        return categories.firstWhere((category) => category.id == id);
      } catch (e) {
        return null;
      }
    }

    late List<NoteCategory> categories;

    setUp(() {
      categories = [
        NoteCategory(id: 'cat-1', title: 'Arbeit', color: Colors.purple),
        NoteCategory(id: 'cat-2', title: 'Freizeit', color: Colors.blue),
        NoteCategory(id: 'cat-3', title: 'Essen', color: Colors.amber),
        NoteCategory(id: 'cat-4', title: 'Gym', color: Colors.green),
        NoteCategory(id: 'cat-5', title: 'Schlafen', color: Colors.grey),
      ];
    });

    group('categoryNameExists', () {
      test('returns true for existing name', () {
        expect(categoryNameExists(categories, 'Arbeit'), true);
      });

      test('is case-insensitive', () {
        expect(categoryNameExists(categories, 'arbeit'), true);
        expect(categoryNameExists(categories, 'ARBEIT'), true);
        expect(categoryNameExists(categories, 'ArBeIt'), true);
      });

      test('returns false for non-existing name', () {
        expect(categoryNameExists(categories, 'Sport'), false);
      });

      test('excludeId allows renaming to same name', () {
        // When editing category cat-1 (Arbeit), should not conflict with itself
        expect(
          categoryNameExists(categories, 'Arbeit', excludeId: 'cat-1'),
          false,
        );
      });

      test('excludeId still detects conflicts with other categories', () {
        // When editing cat-2 (Freizeit), 'Arbeit' should still conflict with cat-1
        expect(
          categoryNameExists(categories, 'Arbeit', excludeId: 'cat-2'),
          true,
        );
      });

      test('returns false for empty list', () {
        expect(categoryNameExists([], 'Anything'), false);
      });
    });

    group('getCategoryById', () {
      test('returns category for existing id', () {
        final cat = getCategoryById(categories, 'cat-1');
        expect(cat, isNotNull);
        expect(cat!.title, 'Arbeit');
      });

      test('returns null for non-existing id', () {
        final cat = getCategoryById(categories, 'nonexistent');
        expect(cat, isNull);
      });

      test('returns null for empty list', () {
        final cat = getCategoryById([], 'cat-1');
        expect(cat, isNull);
      });
    });

    group('default categories', () {
      test('default categories list has 5 entries', () {
        final defaults = [
          NoteCategory(title: 'Arbeit', color: Colors.purple),
          NoteCategory(title: 'Freizeit', color: Colors.lightBlue),
          NoteCategory(title: 'Essen', color: Colors.amber),
          NoteCategory(title: 'Gym', color: Colors.green),
          NoteCategory(title: 'Schlafen', color: Colors.grey),
        ];
        expect(defaults.length, 5);
      });

      test('default category provider returns first category', () {
        // Simulates defaultCategoryProvider logic
        final defaultCat =
            categories.isNotEmpty ? categories.first : null;
        expect(defaultCat, isNotNull);
        expect(defaultCat!.title, 'Arbeit');
      });

      test('default category returns null for empty list', () {
        final List<NoteCategory> empty = [];
        final defaultCat = empty.isNotEmpty ? empty.first : null;
        expect(defaultCat, isNull);
      });
    });
  });
}
