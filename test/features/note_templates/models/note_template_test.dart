import 'dart:convert';

import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteTemplate', () {
    NoteTemplate createSampleTemplate() {
      return NoteTemplate(
        id: 'template-1',
        title: 'Gym Session',
        description: 'Default gym workout',
        durationMinutes: 60,
        noteCategory: availableNoteCategories[3], // Gym
        descriptionSections: [
          const DescriptionSection(title: 'Warm-up', hint: '10 min cardio'),
          const DescriptionSection(title: 'Main Set', hint: 'Exercises'),
          const DescriptionSection(title: 'Cool-down', hint: 'Stretching'),
        ],
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final template = createSampleTemplate();
        expect(template.id, 'template-1');
        expect(template.title, 'Gym Session');
        expect(template.description, 'Default gym workout');
        expect(template.durationMinutes, 60);
        expect(template.noteCategory.title, 'Gym');
        expect(template.descriptionSections.length, 3);
      });

      test('auto-generates UUID if id is not provided', () {
        final template = NoteTemplate(
          title: 'Test',
          description: '',
          durationMinutes: 30,
          noteCategory: availableNoteCategories.first,
        );
        expect(template.id, isNotNull);
        expect(template.id, isNotEmpty);
      });

      test('fromEmpty creates valid empty template', () {
        final template = NoteTemplate.fromEmpty();
        expect(template.id, isNotNull);
        expect(template.title, '');
        expect(template.description, '');
        expect(template.durationMinutes, 30);
        expect(template.noteCategory, availableNoteCategories.first);
        expect(template.descriptionSections, isEmpty);
      });
    });

    group('hasDescriptionSections', () {
      test('returns true when sections exist', () {
        final template = createSampleTemplate();
        expect(template.hasDescriptionSections, true);
      });

      test('returns false when sections are empty', () {
        final template = NoteTemplate.fromEmpty();
        expect(template.hasDescriptionSections, false);
      });
    });

    group('generateDescription', () {
      test('creates formatted output from sections', () {
        final template = createSampleTemplate();
        final generated = template.generateDescription();
        expect(generated, contains('Warm-up:'));
        expect(generated, contains('Main Set:'));
        expect(generated, contains('Cool-down:'));
      });

      test('returns plain description when no sections', () {
        final template = NoteTemplate(
          title: 'Simple',
          description: 'Just a description',
          durationMinutes: 15,
          noteCategory: availableNoteCategories.first,
        );
        expect(template.generateDescription(), 'Just a description');
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = createSampleTemplate();
        final copy = original.copyWith(title: 'Updated Gym');

        expect(copy.title, 'Updated Gym');
        expect(copy.id, original.id);
        expect(copy.description, original.description);
        expect(copy.durationMinutes, original.durationMinutes);
        expect(copy.noteCategory, original.noteCategory);
        expect(copy.descriptionSections.length,
            original.descriptionSections.length);
      });

      test('can update all fields', () {
        final original = createSampleTemplate();
        final copy = original.copyWith(
          id: 'new-id',
          title: 'New Template',
          description: 'New description',
          durationMinutes: 90,
          noteCategory: availableNoteCategories[0],
          descriptionSections: [],
        );

        expect(copy.id, 'new-id');
        expect(copy.title, 'New Template');
        expect(copy.description, 'New description');
        expect(copy.durationMinutes, 90);
        expect(copy.noteCategory.title, 'Work');
        expect(copy.descriptionSections, isEmpty);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleTemplate();
        final map = original.toMap();
        final restored = NoteTemplate.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.description, original.description);
        expect(restored.durationMinutes, original.durationMinutes);
        expect(restored.noteCategory.title, original.noteCategory.title);
        expect(restored.descriptionSections.length,
            original.descriptionSections.length);
      });

      test('map contains correct keys', () {
        final template = createSampleTemplate();
        final map = template.toMap();

        expect(map, contains('id'));
        expect(map, contains('title'));
        expect(map, contains('description'));
        expect(map, contains('durationMinutes'));
        expect(map, contains('noteCategory'));
        expect(map, contains('descriptionSections'));
      });

      test('round-trip without description sections', () {
        final template = NoteTemplate(
          id: 'no-sections',
          title: 'Simple',
          description: 'No sections',
          durationMinutes: 15,
          noteCategory: availableNoteCategories.first,
        );
        final map = template.toMap();
        final restored = NoteTemplate.fromMap(map);

        expect(restored.descriptionSections, isEmpty);
      });
    });

    group('toJson', () {
      test('produces valid JSON string', () {
        final template = createSampleTemplate();
        final jsonStr = template.toJson();

        expect(() => json.decode(jsonStr), returnsNormally);
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        expect(decoded['title'], 'Gym Session');
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip through toDbMap/fromDbMap', () {
        final original = createSampleTemplate();
        final localDbMap = original.toDbMap();
        final restored = NoteTemplate.fromDbMap(localDbMap);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.durationMinutes, original.durationMinutes);
      });
    });

    group('getId', () {
      test('returns template id', () {
        final template = createSampleTemplate();
        expect(template.getId(), 'template-1');
      });
    });
  });
}
