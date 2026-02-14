import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON Serialization for Export/Import', () {
    group('DiaryDay list serialization', () {
      test('list to JSON and back', () {
        final diaryDays = [
          DiaryDay(
            day: DateTime(2024, 3, 10),
            ratings: [
              DayRating(dayRating: DayRatings.social, score: 4),
              DayRating(dayRating: DayRatings.productivity, score: 3),
            ],
          ),
          DiaryDay(
            day: DateTime(2024, 3, 11),
            ratings: [
              DayRating(dayRating: DayRatings.sport, score: 5),
              DayRating(dayRating: DayRatings.food, score: 2),
            ],
          ),
        ];

        // Serialize to JSON
        final jsonList = diaryDays.map((d) => d.toMap()).toList();
        final jsonString = json.encode(jsonList);

        // Deserialize back
        final decoded = json.decode(jsonString) as List;
        final restored = decoded
            .map((d) => DiaryDay.fromMap(d as Map<String, dynamic>))
            .toList();

        expect(restored.length, 2);
        expect(Utils.toDate(restored[0].day), Utils.toDate(diaryDays[0].day));
        expect(restored[0].ratings.length, 2);
        expect(restored[0].ratings[0].dayRating, DayRatings.social);
        expect(restored[0].ratings[0].score, 4);
        expect(Utils.toDate(restored[1].day), Utils.toDate(diaryDays[1].day));
        expect(restored[1].ratings[0].score, 5);
      });

      test('empty list serialization', () {
        final jsonString = json.encode([]);
        final decoded = json.decode(jsonString) as List;
        expect(decoded, isEmpty);
      });

      test('diary day with notes serialization', () {
        final diaryDay = DiaryDay(
          day: DateTime(2024, 3, 15),
          ratings: [DayRating(dayRating: DayRatings.social, score: 3)],
        );
        diaryDay.notes = [
          Note(
            id: 'note-in-diary',
            title: 'Meeting',
            description: 'Team sync',
            from: DateTime(2024, 3, 15, 10, 0),
            to: DateTime(2024, 3, 15, 11, 0),
            noteCategory: availableNoteCategories.first,
          ),
        ];

        final jsonString = json.encode(diaryDay.toMap());
        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        final restored = DiaryDay.fromMap(decoded);

        expect(restored.notes.length, 1);
        expect(restored.notes[0].title, 'Meeting');
      });
    });

    group('Note list serialization', () {
      test('list to JSON and back', () {
        final notes = [
          Note(
            id: 'note-1',
            title: 'Work Task',
            description: 'Complete the report',
            from: DateTime(2024, 3, 15, 9, 0),
            to: DateTime(2024, 3, 15, 17, 0),
            isAllDay: false,
            noteCategory: availableNoteCategories[0], // Arbeit
          ),
          Note(
            id: 'note-2',
            title: 'Lunch',
            description: 'Restaurant downtown',
            from: DateTime(2024, 3, 15, 12, 0),
            to: DateTime(2024, 3, 15, 13, 0),
            isAllDay: false,
            noteCategory: availableNoteCategories[2], // Essen
          ),
        ];

        final jsonList = notes.map((n) => n.toMap()).toList();
        final jsonString = json.encode(jsonList);

        final decoded = json.decode(jsonString) as List;
        final restored = decoded
            .map((n) => Note.fromMap(n as Map<String, dynamic>))
            .toList();

        expect(restored.length, 2);
        expect(restored[0].id, 'note-1');
        expect(restored[0].title, 'Work Task');
        expect(restored[1].id, 'note-2');
        expect(restored[1].noteCategory.title, 'Essen');
      });

      test('all-day note serialization', () {
        final note = Note(
          id: 'allday-note',
          title: 'Vacation',
          description: 'Beach trip',
          from: DateTime(2024, 7, 1),
          to: DateTime(2024, 7, 8),
          isAllDay: true,
          noteCategory: availableNoteCategories[1], // Freizeit
        );

        final jsonString = json.encode(note.toMap());
        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        final restored = Note.fromMap(decoded);

        expect(restored.isAllDay, true);
        expect(restored.title, 'Vacation');
      });
    });

    group('NoteTemplate list serialization', () {
      test('list to JSON and back', () {
        final templates = [
          NoteTemplate(
            id: 'tmpl-1',
            title: 'Morning Routine',
            description: 'Daily morning checklist',
            durationMinutes: 45,
            noteCategory: availableNoteCategories[3], // Gym
            descriptionSections: [
              const DescriptionSection(title: 'Stretching', hint: '5 min'),
              const DescriptionSection(title: 'Cardio', hint: '20 min'),
            ],
          ),
          NoteTemplate(
            id: 'tmpl-2',
            title: 'Quick Meeting',
            description: 'Short standup',
            durationMinutes: 15,
            noteCategory: availableNoteCategories[0], // Arbeit
          ),
        ];

        final jsonList = templates.map((t) => t.toMap()).toList();
        final jsonString = json.encode(jsonList);

        final decoded = json.decode(jsonString) as List;
        final restored = decoded
            .map((t) => NoteTemplate.fromMap(t as Map<String, dynamic>))
            .toList();

        expect(restored.length, 2);
        expect(restored[0].id, 'tmpl-1');
        expect(restored[0].title, 'Morning Routine');
        expect(restored[0].durationMinutes, 45);
        expect(restored[0].descriptionSections.length, 2);
        expect(restored[0].descriptionSections[0].title, 'Stretching');
        expect(restored[1].id, 'tmpl-2');
        expect(restored[1].descriptionSections, isEmpty);
      });
    });

    group('Mixed data export', () {
      test('combined export with all data types', () {
        final exportData = {
          'version': '1.0',
          'exportDate': Utils.toDateTime(DateTime.now()),
          'diaryDays': [
            DiaryDay(
              day: DateTime(2024, 3, 15),
              ratings: [
                DayRating(dayRating: DayRatings.social, score: 4),
              ],
            ).toMap(),
          ],
          'notes': [
            Note(
              id: 'export-note-1',
              title: 'Exported Note',
              description: 'Test',
              from: DateTime(2024, 3, 15, 10, 0),
              to: DateTime(2024, 3, 15, 11, 0),
              noteCategory: availableNoteCategories.first,
            ).toMap(),
          ],
          'templates': [
            NoteTemplate(
              id: 'export-tmpl-1',
              title: 'Exported Template',
              description: 'Test',
              durationMinutes: 30,
              noteCategory: availableNoteCategories.first,
            ).toMap(),
          ],
        };

        final jsonString = json.encode(exportData);
        final decoded = json.decode(jsonString) as Map<String, dynamic>;

        expect(decoded['version'], '1.0');

        final diaryDays = (decoded['diaryDays'] as List)
            .map((d) => DiaryDay.fromMap(d as Map<String, dynamic>))
            .toList();
        expect(diaryDays.length, 1);

        final notes = (decoded['notes'] as List)
            .map((n) => Note.fromMap(n as Map<String, dynamic>))
            .toList();
        expect(notes.length, 1);
        expect(notes[0].title, 'Exported Note');

        final templates = (decoded['templates'] as List)
            .map((t) => NoteTemplate.fromMap(t as Map<String, dynamic>))
            .toList();
        expect(templates.length, 1);
        expect(templates[0].title, 'Exported Template');
      });
    });

    group('Encryption round-trip for export', () {
      test('JSON data survives string encoding for encryption', () {
        // Simulate what happens during encrypted export:
        // data -> JSON string -> encrypt -> decrypt -> JSON string -> data
        final note = Note(
          id: 'encrypt-test',
          title: 'Secret Note',
          description: 'Confidential info',
          from: DateTime(2024, 3, 15, 10, 0),
          to: DateTime(2024, 3, 15, 11, 0),
          noteCategory: availableNoteCategories.first,
        );

        // Serialize to JSON string
        final jsonString = json.encode(note.toMap());

        // Simulate encrypt/decrypt by encoding/decoding UTF-8
        final bytes = utf8.encode(jsonString);
        final restoredJsonString = utf8.decode(bytes);

        // Deserialize back
        final decoded =
            json.decode(restoredJsonString) as Map<String, dynamic>;
        final restored = Note.fromMap(decoded);

        expect(restored.id, note.id);
        expect(restored.title, note.title);
        expect(restored.description, note.description);
      });
    });
  });
}
