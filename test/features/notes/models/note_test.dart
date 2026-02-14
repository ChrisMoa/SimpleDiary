import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Note', () {
    Note createSampleNote() {
      return Note(
        id: 'test-id-123',
        title: 'Morning Workout',
        description: 'Went for a run in the park',
        from: DateTime(2024, 3, 15, 7, 0),
        to: DateTime(2024, 3, 15, 8, 30),
        isAllDay: false,
        noteCategory: availableNoteCategories[3], // Gym
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final note = createSampleNote();
        expect(note.id, 'test-id-123');
        expect(note.title, 'Morning Workout');
        expect(note.description, 'Went for a run in the park');
        expect(note.from, DateTime(2024, 3, 15, 7, 0));
        expect(note.to, DateTime(2024, 3, 15, 8, 30));
        expect(note.isAllDay, false);
        expect(note.noteCategory.title, 'Gym');
      });

      test('auto-generates UUID if id is not provided', () {
        final note = Note(
          title: 'Test',
          description: '',
          from: DateTime.now(),
          to: DateTime.now().add(const Duration(hours: 1)),
          noteCategory: availableNoteCategories.first,
        );
        expect(note.id, isNotNull);
        expect(note.id, isNotEmpty);
      });

      test('fromEmpty creates valid empty note', () {
        final note = Note.fromEmpty();
        expect(note.id, isNotNull);
        expect(note.title, '');
        expect(note.description, '');
        expect(note.isAllDay, false);
        expect(note.noteCategory, availableNoteCategories.first);
        // to should be after from
        expect(note.to.isAfter(note.from), true);
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = createSampleNote();
        final copy = original.copyWith(title: 'Updated Title');

        expect(copy.title, 'Updated Title');
        expect(copy.id, original.id);
        expect(copy.description, original.description);
        expect(copy.from, original.from);
        expect(copy.to, original.to);
        expect(copy.isAllDay, original.isAllDay);
        expect(copy.noteCategory, original.noteCategory);
      });

      test('can update all fields', () {
        final original = createSampleNote();
        final newCategory = availableNoteCategories[1]; // Leisure
        final copy = original.copyWith(
          id: 'new-id',
          title: 'New Title',
          description: 'New Description',
          from: DateTime(2024, 4, 1, 10, 0),
          to: DateTime(2024, 4, 1, 12, 0),
          isAllDay: true,
          noteCategory: newCategory,
        );

        expect(copy.id, 'new-id');
        expect(copy.title, 'New Title');
        expect(copy.description, 'New Description');
        expect(copy.from, DateTime(2024, 4, 1, 10, 0));
        expect(copy.to, DateTime(2024, 4, 1, 12, 0));
        expect(copy.isAllDay, true);
        expect(copy.noteCategory, newCategory);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleNote();
        final map = original.toMap();
        final restored = Note.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.description, original.description);
        expect(Utils.toDateTime(restored.from), Utils.toDateTime(original.from));
        expect(Utils.toDateTime(restored.to), Utils.toDateTime(original.to));
        expect(restored.isAllDay, original.isAllDay);
        expect(restored.noteCategory.title, original.noteCategory.title);
      });

      test('map contains correct keys', () {
        final note = createSampleNote();
        final map = note.toMap();

        expect(map, contains('id'));
        expect(map, contains('title'));
        expect(map, contains('description'));
        expect(map, contains('from'));
        expect(map, contains('to'));
        expect(map, contains('isAllDay'));
        expect(map, contains('noteCategory'));
      });

      test('all-day note round-trip', () {
        final note = Note(
          id: 'allday-1',
          title: 'Holiday',
          description: 'Day off',
          from: DateTime(2024, 12, 25, 0, 0),
          to: DateTime(2024, 12, 25, 23, 59),
          isAllDay: true,
          noteCategory: availableNoteCategories[1], // Leisure
        );

        final map = note.toMap();
        final restored = Note.fromMap(map);
        expect(restored.isAllDay, true);
        expect(restored.title, 'Holiday');
      });
    });

    group('toJson', () {
      test('produces valid JSON string', () {
        final note = createSampleNote();
        final jsonStr = note.toJson();

        expect(() => json.decode(jsonStr), returnsNormally);
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        expect(decoded['title'], 'Morning Workout');
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip with isAllDay as int', () {
        final original = createSampleNote();
        final localDbMap = original.toLocalDbMap(original);

        // isAllDay should be stored as int (0 or 1)
        expect(localDbMap['isAllDay'], 0);

        // Uses fromDate/toDate keys
        expect(localDbMap, contains('fromDate'));
        expect(localDbMap, contains('toDate'));

        final restored = original.fromLocalDbMap(localDbMap) as Note;
        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.isAllDay, false);
      });

      test('isAllDay true converts to 1', () {
        final note = Note(
          title: 'All Day',
          description: '',
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 1, 2),
          isAllDay: true,
          noteCategory: availableNoteCategories.first,
        );
        final localDbMap = note.toLocalDbMap(note);
        expect(localDbMap['isAllDay'], 1);
      });
    });

    group('getId', () {
      test('returns the note id', () {
        final note = createSampleNote();
        expect(note.getId(), 'test-id-123');
      });
    });
  });
}
