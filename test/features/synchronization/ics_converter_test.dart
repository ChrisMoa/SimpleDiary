import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/synchronization/data/repositories/ics_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IcsConverter', () {
    late IcsConverter converter;
    late List<NoteCategory> testCategories;

    setUp(() {
      converter = IcsConverter();
      testCategories = List.from(availableNoteCategories);
    });

    Note createTimedNote() {
      return Note(
        id: 'note-timed-1',
        title: 'Team Meeting',
        description: 'Weekly standup',
        from: DateTime(2024, 3, 15, 10, 0),
        to: DateTime(2024, 3, 15, 11, 0),
        isAllDay: false,
        noteCategory: availableNoteCategories[0], // Work
      );
    }

    Note createAllDayNote() {
      return Note(
        id: 'note-allday-1',
        title: 'Holiday',
        description: 'National holiday',
        from: DateTime(2024, 12, 25),
        to: DateTime(2024, 12, 26),
        isAllDay: true,
        noteCategory: availableNoteCategories[1], // Leisure
      );
    }

    group('noteToIcsEvent', () {
      test('converts timed note to VEvent', () {
        final note = createTimedNote();
        final event = converter.noteToIcsEvent(note);

        expect(event.uid, 'note-timed-1');
        expect(event.summary, 'Team Meeting');
        expect(event.description, 'Weekly standup');
        expect(event.categories, contains('Work'));
      });

      test('converts all-day note to VEvent', () {
        final note = createAllDayNote();
        final event = converter.noteToIcsEvent(note);

        expect(event.uid, 'note-allday-1');
        expect(event.summary, 'Holiday');
      });

      test('sets category from noteCategory title', () {
        final note = createTimedNote();
        final event = converter.noteToIcsEvent(note);
        expect(event.categories, isNotNull);
        expect(event.categories!.first, 'Work');
      });
    });

    group('createCalendar', () {
      test('creates calendar with multiple events', () {
        final notes = [createTimedNote(), createAllDayNote()];
        final calendar = converter.createCalendar(notes);

        expect(calendar.children.length, 2);
        expect(calendar.productId,
            '-//SimpleDiary//SimpleDiary Flutter App//EN');
      });

      test('creates empty calendar with no notes', () {
        final calendar = converter.createCalendar([]);
        expect(calendar.children, isEmpty);
      });
    });

    group('icsEventsToNotes', () {
      test('converts ICS events back to notes with known categories', () {
        final originalNotes = [createTimedNote()];
        final calendar = converter.createCalendar(originalNotes);
        final restoredNotes =
            converter.icsEventsToNotes(calendar, testCategories);

        expect(restoredNotes.length, 1);
        expect(restoredNotes[0].title, 'Team Meeting');
        expect(restoredNotes[0].description, 'Weekly standup');
        expect(restoredNotes[0].noteCategory.title, 'Work');
      });

      test('handles unknown category with fallback', () {
        final note = Note(
          id: 'note-custom',
          title: 'Custom',
          description: '',
          from: DateTime(2024, 3, 15, 10, 0),
          to: DateTime(2024, 3, 15, 11, 0),
          isAllDay: false,
          noteCategory: NoteCategory(title: 'CustomCat', color: Colors.pink),
        );

        final calendar = converter.createCalendar([note]);
        final restoredNotes =
            converter.icsEventsToNotes(calendar, testCategories);

        expect(restoredNotes.length, 1);
        // Should fall back to first available category since 'CustomCat' is not in testCategories
        expect(restoredNotes[0].noteCategory.title, testCategories.first.title);
      });

      test('returns empty list for calendar with no events', () {
        final calendar = converter.createCalendar([]);
        final restoredNotes =
            converter.icsEventsToNotes(calendar, testCategories);
        expect(restoredNotes, isEmpty);
      });
    });

    group('ICS string round-trip', () {
      test('calendarToString produces valid ICS text', () {
        final notes = [createTimedNote()];
        final calendar = converter.createCalendar(notes);
        final icsString = converter.calendarToString(calendar);

        expect(icsString, contains('BEGIN:VCALENDAR'));
        expect(icsString, contains('END:VCALENDAR'));
        expect(icsString, contains('BEGIN:VEVENT'));
        expect(icsString, contains('END:VEVENT'));
        expect(icsString, contains('Team Meeting'));
      });

      test('stringToCalendar parses valid ICS string', () {
        final notes = [createTimedNote()];
        final calendar = converter.createCalendar(notes);
        final icsString = converter.calendarToString(calendar);

        final parsedCalendar = converter.stringToCalendar(icsString);
        expect(parsedCalendar, isNotNull);
      });

      test('throws on invalid ICS string', () {
        expect(
          () => converter.stringToCalendar('not valid ics'),
          throwsA(anything),
        );
      });
    });

    group('multiple notes round-trip through ICS', () {
      test('round-trip preserves all notes', () {
        final originalNotes = [
          createTimedNote(),
          createAllDayNote(),
          Note(
            id: 'note-3',
            title: 'Gym Workout',
            description: 'Leg day',
            from: DateTime(2024, 3, 15, 18, 0),
            to: DateTime(2024, 3, 15, 19, 30),
            isAllDay: false,
            noteCategory: availableNoteCategories[3], // Gym
          ),
        ];

        final calendar = converter.createCalendar(originalNotes);
        final icsString = converter.calendarToString(calendar);
        final parsedCalendar = converter.stringToCalendar(icsString);
        final restoredNotes =
            converter.icsEventsToNotes(parsedCalendar, testCategories);

        expect(restoredNotes.length, originalNotes.length);

        // Verify titles are preserved
        final restoredTitles =
            restoredNotes.map((n) => n.title).toSet();
        expect(restoredTitles, contains('Team Meeting'));
        expect(restoredTitles, contains('Holiday'));
        expect(restoredTitles, contains('Gym Workout'));
      });
    });
  });
}
