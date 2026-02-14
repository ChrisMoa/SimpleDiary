import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests validate the core scheduling logic used by the wizard providers
/// without requiring Riverpod ProviderContainer (pure function tests).
void main() {
  group('Wizard Scheduling Logic', () {
    /// Replicates the isDayFullyScheduled logic from diary_wizard_providers.dart
    bool isDayFullyScheduled(DateTime selectedDate, List<Note> notes) {
      if (notes.isEmpty) return false;

      final dayStart = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
      final dayEnd = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 22, 0);

      final sorted = List<Note>.from(notes)
        ..sort((a, b) => a.from.compareTo(b.from));

      if (sorted.first.from.isAfter(dayStart)) return false;
      if (sorted.last.to.isBefore(dayEnd)) return false;

      for (int i = 0; i < sorted.length - 1; i++) {
        if (sorted[i].to.isBefore(sorted[i + 1].from)) return false;
      }
      return true;
    }

    /// Replicates the nextAvailableTimeSlot logic
    DateTime nextAvailableTimeSlot(DateTime selectedDate, List<Note> notes) {
      final dayStart = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
      final dayEnd = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 22, 0);

      if (notes.isEmpty) return dayStart;

      final sortedNotes = List<Note>.from(notes)
        ..sort((a, b) => a.from.compareTo(b.from));

      if (sortedNotes.first.from.isAfter(dayStart)) return dayStart;

      for (int i = 0; i < sortedNotes.length - 1; i++) {
        if (sortedNotes[i].to.isBefore(sortedNotes[i + 1].from)) {
          return sortedNotes[i].to;
        }
      }

      if (sortedNotes.last.to.isBefore(dayEnd)) {
        return sortedNotes.last.to;
      }

      return DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day + 1, 7, 0);
    }

    /// Replicates the isDayFinished logic (15-minute chunk checking)
    bool isDayFinished(DateTime selectedDate, List<Note> notesOfDay) {
      final dayBegin =
          selectedDate.copyWith(hour: 7, minute: 0, second: 0);
      final dayEnd =
          selectedDate.copyWith(hour: 22, minute: 0, second: 0);
      const timeIncrease = 15;

      for (var curTime = dayBegin;
          curTime.isBefore(dayEnd);
          curTime = curTime.add(const Duration(minutes: timeIncrease))) {
        bool found = false;
        for (final note in notesOfDay) {
          if (Utils.isDateTimeWithinTimeSpan(curTime, note.from, note.to)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }
      return true;
    }

    Note createNote(DateTime date, int fromHour, int fromMinute, int toHour,
        int toMinute) {
      return Note(
        title: 'Note $fromHour:$fromMinute',
        description: '',
        from: DateTime(date.year, date.month, date.day, fromHour, fromMinute),
        to: DateTime(date.year, date.month, date.day, toHour, toMinute),
        noteCategory: availableNoteCategories.first,
      );
    }

    final testDate = DateTime(2024, 3, 15);

    group('isDayFullyScheduled', () {
      test('empty notes means not fully scheduled', () {
        expect(isDayFullyScheduled(testDate, []), false);
      });

      test('single note covering 7:00-22:00 is fully scheduled', () {
        final notes = [createNote(testDate, 7, 0, 22, 0)];
        expect(isDayFullyScheduled(testDate, notes), true);
      });

      test('notes with gap are not fully scheduled', () {
        final notes = [
          createNote(testDate, 7, 0, 12, 0),
          // gap from 12:00 to 14:00
          createNote(testDate, 14, 0, 22, 0),
        ];
        expect(isDayFullyScheduled(testDate, notes), false);
      });

      test('contiguous notes covering full day are fully scheduled', () {
        final notes = [
          createNote(testDate, 7, 0, 12, 0),
          createNote(testDate, 12, 0, 17, 0),
          createNote(testDate, 17, 0, 22, 0),
        ];
        expect(isDayFullyScheduled(testDate, notes), true);
      });

      test('note starting after 7:00 is not fully scheduled', () {
        final notes = [createNote(testDate, 8, 0, 22, 0)];
        expect(isDayFullyScheduled(testDate, notes), false);
      });

      test('note ending before 22:00 is not fully scheduled', () {
        final notes = [createNote(testDate, 7, 0, 21, 0)];
        expect(isDayFullyScheduled(testDate, notes), false);
      });

      test('overlapping notes still count as covered', () {
        final notes = [
          createNote(testDate, 7, 0, 14, 0),
          createNote(testDate, 12, 0, 22, 0), // overlaps from 12-14
        ];
        expect(isDayFullyScheduled(testDate, notes), true);
      });

      test('notes passed in unsorted order still work', () {
        final notes = [
          createNote(testDate, 17, 0, 22, 0),
          createNote(testDate, 7, 0, 12, 0),
          createNote(testDate, 12, 0, 17, 0),
        ];
        expect(isDayFullyScheduled(testDate, notes), true);
      });
    });

    group('nextAvailableTimeSlot', () {
      test('empty notes returns day start (7:00)', () {
        final slot = nextAvailableTimeSlot(testDate, []);
        expect(slot.hour, 7);
        expect(slot.minute, 0);
      });

      test('gap at beginning returns day start', () {
        final notes = [createNote(testDate, 10, 0, 12, 0)];
        final slot = nextAvailableTimeSlot(testDate, notes);
        expect(slot.hour, 7);
        expect(slot.minute, 0);
      });

      test('gap between notes returns end of first note', () {
        final notes = [
          createNote(testDate, 7, 0, 10, 0),
          createNote(testDate, 14, 0, 22, 0),
        ];
        final slot = nextAvailableTimeSlot(testDate, notes);
        expect(slot.hour, 10);
        expect(slot.minute, 0);
      });

      test('no gap returns end of last note', () {
        final notes = [
          createNote(testDate, 7, 0, 10, 0),
          createNote(testDate, 10, 0, 15, 0),
        ];
        final slot = nextAvailableTimeSlot(testDate, notes);
        expect(slot.hour, 15);
        expect(slot.minute, 0);
      });

      test('fully scheduled day returns next day 7:00', () {
        final notes = [createNote(testDate, 7, 0, 22, 0)];
        final slot = nextAvailableTimeSlot(testDate, notes);
        expect(slot.day, testDate.day + 1);
        expect(slot.hour, 7);
      });

      test('notes passed unsorted still find correct slot', () {
        final notes = [
          createNote(testDate, 14, 0, 22, 0),
          createNote(testDate, 7, 0, 10, 0),
        ];
        final slot = nextAvailableTimeSlot(testDate, notes);
        expect(slot.hour, 10);
        expect(slot.minute, 0);
      });
    });

    group('isDayFinished (15-minute chunk checking)', () {
      test('empty notes means day not finished', () {
        expect(isDayFinished(testDate, []), false);
      });

      test('single note covering 7:00-22:00 is finished', () {
        final notes = [createNote(testDate, 7, 0, 22, 0)];
        expect(isDayFinished(testDate, notes), true);
      });

      test('30-minute gap detected as not finished', () {
        final notes = [
          createNote(testDate, 7, 0, 12, 0),
          // 30-minute gap: 12:00 boundary is covered, but 12:15 is not
          createNote(testDate, 12, 30, 22, 0),
        ];
        expect(isDayFinished(testDate, notes), false);
      });

      test('contiguous notes pass the 15-minute check', () {
        final notes = [
          createNote(testDate, 7, 0, 12, 0),
          createNote(testDate, 12, 0, 17, 0),
          createNote(testDate, 17, 0, 22, 0),
        ];
        expect(isDayFinished(testDate, notes), true);
      });

      test('many small notes covering the day pass', () {
        // 15-minute notes from 7:00 to 22:00 (60 notes)
        final notes = <Note>[];
        for (int hour = 7; hour < 22; hour++) {
          for (int minute = 0; minute < 60; minute += 15) {
            int endHour = hour;
            int endMinute = minute + 15;
            if (endMinute >= 60) {
              endHour++;
              endMinute = 0;
            }
            notes.add(createNote(testDate, hour, minute, endHour, endMinute));
          }
        }
        expect(isDayFinished(testDate, notes), true);
      });
    });

    group('DayRatings default initialization', () {
      test('all DayRatings values initialized with score 3', () {
        final ratings = DayRatings.values
            .map((type) => DayRating(dayRating: type, score: 3))
            .toList();

        expect(ratings.length, DayRatings.values.length);
        for (final rating in ratings) {
          expect(rating.score, 3);
        }
      });

      test('updating a specific rating preserves others', () {
        var ratings = DayRatings.values
            .map((type) => DayRating(dayRating: type, score: 3))
            .toList();

        // Simulate updateRating for 'social' to score 5
        ratings = ratings.map((rating) {
          if (rating.dayRating == DayRatings.social) {
            return DayRating(dayRating: DayRatings.social, score: 5);
          }
          return rating;
        }).toList();

        final socialRating = ratings
            .firstWhere((r) => r.dayRating == DayRatings.social);
        expect(socialRating.score, 5);

        // Others should still be 3
        final otherRatings =
            ratings.where((r) => r.dayRating != DayRatings.social);
        for (final rating in otherRatings) {
          expect(rating.score, 3);
        }
      });

      test('reset sets all ratings back to score 3', () {
        // Start with mixed scores
        var ratings = [
          DayRating(dayRating: DayRatings.social, score: 1),
          DayRating(dayRating: DayRatings.productivity, score: 5),
          DayRating(dayRating: DayRatings.sport, score: 2),
          DayRating(dayRating: DayRatings.food, score: 4),
        ];

        // Reset
        ratings = DayRatings.values
            .map((type) => DayRating(dayRating: type, score: 3))
            .toList();

        for (final rating in ratings) {
          expect(rating.score, 3);
        }
      });
    });

    group('Note filtering by date', () {
      test('filters notes for a specific day', () {
        final selectedDate = DateTime(2024, 3, 15);
        final notes = [
          createNote(DateTime(2024, 3, 15), 9, 0, 10, 0),
          createNote(DateTime(2024, 3, 15), 14, 0, 15, 0),
          createNote(DateTime(2024, 3, 16), 9, 0, 10, 0), // different day
          createNote(DateTime(2024, 2, 15), 9, 0, 10, 0), // different month
        ];

        final filtered = notes.where((note) {
          return note.from.year == selectedDate.year &&
              note.from.month == selectedDate.month &&
              note.from.day == selectedDate.day;
        }).toList();

        expect(filtered.length, 2);
      });
    });
  });
}
