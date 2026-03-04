import 'package:day_tracker/features/dashboard/data/repositories/activity_detail_repository.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ActivityDetailRepository repository;

  setUp(() {
    repository = ActivityDetailRepository();
  });

  // ── Helpers ──────────────────────────────────────────────────────

  final workCategory = NoteCategory(title: 'Work', color: Colors.purple);
  final leisureCategory = NoteCategory(title: 'Leisure', color: Colors.lightBlue);
  final foodCategory = NoteCategory(title: 'Food', color: Colors.amber);

  Note createNote({
    required String title,
    required NoteCategory category,
    required DateTime date,
  }) {
    return Note(
      title: title,
      description: 'Test description',
      from: date,
      to: date.add(const Duration(hours: 1)),
      noteCategory: category,
    );
  }

  DiaryDay createDiaryDay(DateTime date, {int score = 3, List<Note>? notes}) {
    final day = DiaryDay(
      day: date,
      ratings: [
        DayRating(dayRating: DayRatings.social, score: score),
        DayRating(dayRating: DayRatings.productivity, score: score),
        DayRating(dayRating: DayRatings.sport, score: score),
        DayRating(dayRating: DayRatings.food, score: score),
      ],
    );
    day.notes = notes ?? [];
    return day;
  }

  // ── getActivityStats ─────────────────────────────────────────────

  group('getActivityStats', () {
    test('empty notes and days returns zeros', () {
      final stats = repository.getActivityStats(
        activityName: 'Work',
        notes: [],
        diaryDays: [],
      );

      expect(stats.activityName, 'Work');
      expect(stats.totalNotes, 0);
      expect(stats.associatedDays, 0);
      expect(stats.averageDayRating, 0);
      expect(stats.firstOccurrence, isNull);
      expect(stats.lastOccurrence, isNull);
    });

    test('calculates correct stats for activity with notes', () {
      final date1 = DateTime(2026, 1, 10);
      final date2 = DateTime(2026, 1, 15);
      final date3 = DateTime(2026, 1, 20);

      final notes = [
        createNote(title: 'Meeting', category: workCategory, date: date1),
        createNote(title: 'Coding', category: workCategory, date: date2),
        createNote(title: 'Review', category: workCategory, date: date3),
        createNote(title: 'Movie', category: leisureCategory, date: date1),
      ];

      final diaryDays = [
        createDiaryDay(date1, score: 4),
        createDiaryDay(date2, score: 3),
        createDiaryDay(date3, score: 5),
      ];

      final stats = repository.getActivityStats(
        activityName: 'Work',
        notes: notes,
        diaryDays: diaryDays,
      );

      expect(stats.activityName, 'Work');
      expect(stats.totalNotes, 3);
      expect(stats.associatedDays, 3);
      expect(stats.averageDayRating, 16.0); // (16 + 12 + 20) / 3 = 16
      expect(stats.firstOccurrence, date1);
      expect(stats.lastOccurrence, date3);
      expect(stats.category.title, 'Work');
    });

    test('returns zero average when days have no ratings', () {
      final date1 = DateTime(2026, 1, 10);
      final notes = [
        createNote(title: 'Meeting', category: workCategory, date: date1),
      ];
      final diaryDays = [
        DiaryDay(day: date1, ratings: []),
      ];

      final stats = repository.getActivityStats(
        activityName: 'Work',
        notes: notes,
        diaryDays: diaryDays,
      );

      expect(stats.averageDayRating, 0);
    });

    test('category comes from note when notes exist', () {
      final date1 = DateTime(2026, 1, 10);
      final notes = [
        createNote(title: 'Work item', category: workCategory, date: date1),
      ];

      final stats = repository.getActivityStats(
        activityName: 'Work',
        notes: notes,
        diaryDays: [],
      );

      expect(stats.category.color, Colors.purple);
    });

    test('uses fallback category when no notes match', () {
      final stats = repository.getActivityStats(
        activityName: 'Unknown',
        notes: [],
        diaryDays: [],
      );

      expect(stats.category.title, 'Unknown');
    });
  });

  // ── getNotesByActivity ───────────────────────────────────────────

  group('getNotesByActivity', () {
    test('returns empty list for no matching notes', () {
      final notes = [
        createNote(title: 'Movie', category: leisureCategory, date: DateTime(2026, 1, 10)),
      ];

      final result = repository.getNotesByActivity('Work', notes);
      expect(result, isEmpty);
    });

    test('filters notes by activity name', () {
      final notes = [
        createNote(title: 'Meeting', category: workCategory, date: DateTime(2026, 1, 10)),
        createNote(title: 'Movie', category: leisureCategory, date: DateTime(2026, 1, 11)),
        createNote(title: 'Coding', category: workCategory, date: DateTime(2026, 1, 12)),
      ];

      final result = repository.getNotesByActivity('Work', notes);
      expect(result.length, 2);
      expect(result.every((n) => n.noteCategory.title == 'Work'), true);
    });

    test('returns notes sorted by date descending', () {
      final date1 = DateTime(2026, 1, 10);
      final date2 = DateTime(2026, 1, 15);
      final date3 = DateTime(2026, 1, 12);

      final notes = [
        createNote(title: 'A', category: workCategory, date: date1),
        createNote(title: 'B', category: workCategory, date: date2),
        createNote(title: 'C', category: workCategory, date: date3),
      ];

      final result = repository.getNotesByActivity('Work', notes);
      expect(result[0].title, 'B'); // Jan 15 (newest)
      expect(result[1].title, 'C'); // Jan 12
      expect(result[2].title, 'A'); // Jan 10 (oldest)
    });

    test('returns empty list for empty input', () {
      final result = repository.getNotesByActivity('Work', []);
      expect(result, isEmpty);
    });
  });

  // ── getDaysByActivity ────────────────────────────────────────────

  group('getDaysByActivity', () {
    test('returns empty list when no notes match', () {
      final notes = [
        createNote(title: 'Movie', category: leisureCategory, date: DateTime(2026, 1, 10)),
      ];
      final diaryDays = [createDiaryDay(DateTime(2026, 1, 10))];

      final result = repository.getDaysByActivity('Work', notes, diaryDays);
      expect(result, isEmpty);
    });

    test('returns diary days that contain the activity', () {
      final date1 = DateTime(2026, 1, 10);
      final date2 = DateTime(2026, 1, 11);
      final date3 = DateTime(2026, 1, 12);

      final notes = [
        createNote(title: 'Meeting', category: workCategory, date: date1),
        createNote(title: 'Movie', category: leisureCategory, date: date2),
        createNote(title: 'Coding', category: workCategory, date: date3),
      ];

      final diaryDays = [
        createDiaryDay(date1),
        createDiaryDay(date2),
        createDiaryDay(date3),
      ];

      final result = repository.getDaysByActivity('Work', notes, diaryDays);
      expect(result.length, 2);
    });

    test('returns days sorted by date descending', () {
      final date1 = DateTime(2026, 1, 10);
      final date2 = DateTime(2026, 1, 15);

      final notes = [
        createNote(title: 'A', category: workCategory, date: date1),
        createNote(title: 'B', category: workCategory, date: date2),
      ];

      final diaryDays = [
        createDiaryDay(date1),
        createDiaryDay(date2),
      ];

      final result = repository.getDaysByActivity('Work', notes, diaryDays);
      expect(result[0].day, date2); // newest first
      expect(result[1].day, date1);
    });

    test('handles multiple notes on same day', () {
      final date = DateTime(2026, 1, 10);

      final notes = [
        createNote(title: 'Meeting 1', category: workCategory, date: date),
        createNote(title: 'Meeting 2', category: workCategory, date: date.add(const Duration(hours: 2))),
      ];

      final diaryDays = [createDiaryDay(date)];

      final result = repository.getDaysByActivity('Work', notes, diaryDays);
      expect(result.length, 1); // same day, not duplicated
    });

    test('returns empty list for empty inputs', () {
      final result = repository.getDaysByActivity('Work', [], []);
      expect(result, isEmpty);
    });
  });

  // ── extractTopActivitySummaries ──────────────────────────────────

  group('extractTopActivitySummaries', () {
    test('returns empty list for no notes', () {
      final result = repository.extractTopActivitySummaries([], []);
      expect(result, isEmpty);
    });

    test('returns activities sorted by frequency', () {
      final notes = [
        createNote(title: 'A', category: workCategory, date: DateTime(2026, 1, 1)),
        createNote(title: 'B', category: workCategory, date: DateTime(2026, 1, 2)),
        createNote(title: 'C', category: workCategory, date: DateTime(2026, 1, 3)),
        createNote(title: 'D', category: leisureCategory, date: DateTime(2026, 1, 1)),
        createNote(title: 'E', category: foodCategory, date: DateTime(2026, 1, 1)),
        createNote(title: 'F', category: foodCategory, date: DateTime(2026, 1, 2)),
      ];

      final result = repository.extractTopActivitySummaries(notes, []);
      expect(result.length, 3);
      expect(result[0].activityName, 'Work');
      expect(result[0].count, 3);
      expect(result[1].activityName, 'Food');
      expect(result[1].count, 2);
      expect(result[2].activityName, 'Leisure');
      expect(result[2].count, 1);
    });

    test('limits to top 5 activities', () {
      final categories = List.generate(7, (i) =>
          NoteCategory(title: 'Cat$i', color: Colors.blue));
      final notes = <Note>[];
      for (var i = 0; i < 7; i++) {
        for (var j = 0; j <= i; j++) {
          notes.add(createNote(
            title: 'Note$i-$j',
            category: categories[i],
            date: DateTime(2026, 1, j + 1),
          ));
        }
      }

      final result = repository.extractTopActivitySummaries(notes, []);
      expect(result.length, 5);
    });

    test('includes category color from notes', () {
      final notes = [
        createNote(title: 'A', category: workCategory, date: DateTime(2026, 1, 1)),
      ];

      final result = repository.extractTopActivitySummaries(notes, []);
      expect(result[0].category.color, Colors.purple);
    });

    test('single note returns single activity', () {
      final notes = [
        createNote(title: 'A', category: workCategory, date: DateTime(2026, 1, 1)),
      ];

      final result = repository.extractTopActivitySummaries(notes, []);
      expect(result.length, 1);
      expect(result[0].activityName, 'Work');
      expect(result[0].count, 1);
    });
  });

  // ── ActivityStats model ──────────────────────────────────────────

  group('ActivityStats', () {
    test('copyWith preserves unchanged fields', () {
      final stats = ActivityStats(
        activityName: 'Work',
        category: workCategory,
        totalNotes: 5,
        associatedDays: 3,
        averageDayRating: 15.0,
        firstOccurrence: DateTime(2026, 1, 1),
        lastOccurrence: DateTime(2026, 1, 31),
      );

      final copied = stats.copyWith(totalNotes: 10);
      expect(copied.activityName, 'Work');
      expect(copied.totalNotes, 10);
      expect(copied.associatedDays, 3);
      expect(copied.averageDayRating, 15.0);
    });

    test('copyWith updates all fields', () {
      final stats = ActivityStats(
        activityName: 'Work',
        category: workCategory,
        totalNotes: 5,
        associatedDays: 3,
        averageDayRating: 15.0,
      );

      final newDate = DateTime(2026, 2, 1);
      final copied = stats.copyWith(
        activityName: 'Leisure',
        category: leisureCategory,
        totalNotes: 10,
        associatedDays: 7,
        averageDayRating: 18.0,
        firstOccurrence: newDate,
        lastOccurrence: newDate,
      );

      expect(copied.activityName, 'Leisure');
      expect(copied.category.title, 'Leisure');
      expect(copied.totalNotes, 10);
      expect(copied.associatedDays, 7);
      expect(copied.averageDayRating, 18.0);
      expect(copied.firstOccurrence, newDate);
      expect(copied.lastOccurrence, newDate);
    });
  });

  // ── ActivitySummary model ────────────────────────────────────────

  group('ActivitySummary', () {
    test('construction with all fields', () {
      final summary = ActivitySummary(
        activityName: 'Work',
        category: workCategory,
        count: 5,
      );

      expect(summary.activityName, 'Work');
      expect(summary.category.color, Colors.purple);
      expect(summary.count, 5);
    });
  });
}
