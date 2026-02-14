import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteCategory', () {
    group('availableNoteCategories', () {
      test('contains all default categories', () {
        final titles =
            availableNoteCategories.map((c) => c.title).toList();
        expect(titles, contains('Work'));
        expect(titles, contains('Leisure'));
        expect(titles, contains('Food'));
        expect(titles, contains('Gym'));
        expect(titles, contains('Sleep'));
      });

      test('has exactly 5 defaults', () {
        expect(availableNoteCategories.length, 5);
      });

      test('each default has a color', () {
        for (final category in availableNoteCategories) {
          expect(category.color, isNotNull);
        }
      });
    });

    group('fromString', () {
      test('finds existing category by title', () {
        final category = NoteCategory.fromString('Work');
        expect(category.title, 'Work');
        expect(category.color, Colors.purple);
      });

      test('finds each default category', () {
        for (final defaultCat in availableNoteCategories) {
          final found = NoteCategory.fromString(defaultCat.title);
          expect(found.title, defaultCat.title);
        }
      });

      test('returns blue fallback for unknown category', () {
        final category = NoteCategory.fromString('UnknownCategory');
        expect(category.title, 'UnknownCategory');
        expect(category.color, Colors.blue);
      });

      test('is case-sensitive', () {
        // 'work' (lowercase) should not match 'Work'
        final category = NoteCategory.fromString('work');
        expect(category.color, Colors.blue); // fallback
      });
    });

    group('equality', () {
      test('categories with same title are equal', () {
        final cat1 = NoteCategory(title: 'Test', color: Colors.red);
        final cat2 = NoteCategory(title: 'Test', color: Colors.green);
        expect(cat1, equals(cat2));
      });

      test('categories with different titles are not equal', () {
        final cat1 = NoteCategory(title: 'Test1', color: Colors.red);
        final cat2 = NoteCategory(title: 'Test2', color: Colors.red);
        expect(cat1, isNot(equals(cat2)));
      });

      test('hashCode is based on title', () {
        final cat1 = NoteCategory(title: 'Test', color: Colors.red);
        final cat2 = NoteCategory(title: 'Test', color: Colors.blue);
        expect(cat1.hashCode, equals(cat2.hashCode));
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = NoteCategory(
          id: 'cat-1',
          title: 'Original',
          color: Colors.red,
        );
        final copy = original.copyWith(title: 'Updated');

        expect(copy.title, 'Updated');
        expect(copy.id, 'cat-1');
        expect(copy.color, Colors.red);
      });

      test('can update all fields', () {
        final original = NoteCategory(
          id: 'cat-1',
          title: 'Original',
          color: Colors.red,
        );
        final copy = original.copyWith(
          id: 'cat-2',
          title: 'New',
          color: Colors.blue,
        );

        expect(copy.id, 'cat-2');
        expect(copy.title, 'New');
        expect(copy.color, Colors.blue);
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip with colorValue', () {
        final original = NoteCategory(
          id: 'cat-test',
          title: 'TestCategory',
          color: const Color(0xFF4CAF50),
        );
        final localDbMap = original.toLocalDbMap(original);

        expect(localDbMap['id'], 'cat-test');
        expect(localDbMap['title'], 'TestCategory');
        expect(localDbMap['colorValue'], isA<int>());

        final restored = original.fromLocalDbMap(localDbMap) as NoteCategory;
        expect(restored.id, original.id);
        expect(restored.title, original.title);
      });
    });

    group('auto-generated id', () {
      test('generates UUID if id is not provided', () {
        final cat = NoteCategory(title: 'New', color: Colors.orange);
        expect(cat.id, isNotNull);
        expect(cat.id, isNotEmpty);
      });
    });
  });
}
