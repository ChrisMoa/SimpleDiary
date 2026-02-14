import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterNotes', () {
    // Test data
    final workCategory = NoteCategory(title: 'Work', color: Colors.purple);
    final foodCategory = NoteCategory(title: 'Food', color: Colors.amber);
    final gymCategory = NoteCategory(title: 'Gym', color: Colors.green);

    final testNotes = [
      Note(
        title: 'Morning Meeting',
        description: 'Discussed Q1 goals and project planning',
        from: DateTime(2026, 1, 15, 9, 0),
        to: DateTime(2026, 1, 15, 10, 0),
        noteCategory: workCategory,
      ),
      Note(
        title: 'Lunch',
        description: 'Had pizza with friends at the restaurant',
        from: DateTime(2026, 1, 15, 12, 0),
        to: DateTime(2026, 1, 15, 13, 0),
        noteCategory: foodCategory,
      ),
      Note(
        title: 'Gym Session',
        description: 'Leg day exercises and cardio',
        from: DateTime(2026, 1, 16, 17, 0),
        to: DateTime(2026, 1, 16, 18, 0),
        noteCategory: gymCategory,
      ),
      Note(
        title: 'Team Planning',
        description: 'Weekly planning session with the team',
        from: DateTime(2026, 1, 17, 10, 0),
        to: DateTime(2026, 1, 17, 11, 0),
        noteCategory: workCategory,
      ),
    ];

    test('empty search returns all notes sorted by date descending', () {
      final result = filterNotes(testNotes, const NoteSearchState());

      expect(result.length, 4);
      // Check descending order (most recent first)
      expect(result[0].title, 'Team Planning'); // Jan 17
      expect(result[1].title, 'Gym Session'); // Jan 16
      expect(result[2].title, 'Lunch'); // Jan 15, 12:00
      expect(result[3].title, 'Morning Meeting'); // Jan 15, 09:00
    });

    test('text search filters by title (case-insensitive)', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'meeting'),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Morning Meeting');
    });

    test('text search filters by description', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'pizza'),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Lunch');
    });

    test('text search is case-insensitive', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'PLANNING'),
      );

      expect(result.length, 2);
      // Both "Morning Meeting" (description) and "Team Planning" (title)
      expect(result.any((n) => n.title == 'Morning Meeting'), true);
      expect(result.any((n) => n.title == 'Team Planning'), true);
    });

    test('text search matches partial words', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'plan'),
      );

      expect(result.length, 2);
      expect(result.any((n) => n.title == 'Morning Meeting'), true);
      expect(result.any((n) => n.title == 'Team Planning'), true);
    });

    test('text search in title OR description', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'session'),
      );

      expect(result.length, 2);
      expect(result.any((n) => n.title == 'Gym Session'), true);
      expect(result.any((n) => n.title == 'Team Planning'), true);
    });

    test('category filter returns only matching category', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(categoryFilter: workCategory),
      );

      expect(result.length, 2);
      expect(result.every((n) => n.noteCategory.title == 'Work'), true);
    });

    test('category filter with different category', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(categoryFilter: gymCategory),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Gym Session');
    });

    test('date range filter includes notes within range (single day)', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 2);
      expect(result.any((n) => n.title == 'Morning Meeting'), true);
      expect(result.any((n) => n.title == 'Lunch'), true);
    });

    test('date range filter includes notes within range (multiple days)', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 16),
        ),
      );

      expect(result.length, 3);
      expect(result.any((n) => n.title == 'Morning Meeting'), true);
      expect(result.any((n) => n.title == 'Lunch'), true);
      expect(result.any((n) => n.title == 'Gym Session'), true);
    });

    test('dateFrom filter only (no upper bound)', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          dateFrom: DateTime(2026, 1, 16),
        ),
      );

      expect(result.length, 2);
      expect(result.any((n) => n.title == 'Gym Session'), true);
      expect(result.any((n) => n.title == 'Team Planning'), true);
    });

    test('dateTo filter only (no lower bound)', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 2);
      expect(result.any((n) => n.title == 'Morning Meeting'), true);
      expect(result.any((n) => n.title == 'Lunch'), true);
    });

    test('combined filters: text + category', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          query: 'planning',
          categoryFilter: workCategory,
        ),
      );

      expect(result.length, 2);
      expect(result.every((n) => n.noteCategory.title == 'Work'), true);
    });

    test('combined filters: text + date range', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          query: 'meeting',
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Morning Meeting');
    });

    test('combined filters: category + date range', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          categoryFilter: workCategory,
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Morning Meeting');
    });

    test('combined filters: all filters (text + category + date)', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(
          query: 'goals',
          categoryFilter: workCategory,
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 1);
      expect(result.first.title, 'Morning Meeting');
    });

    test('no match returns empty list', () {
      final result = filterNotes(
        testNotes,
        const NoteSearchState(query: 'nonexistent'),
      );

      expect(result, isEmpty);
    });

    test('results are sorted by date descending', () {
      final result = filterNotes(
        testNotes,
        NoteSearchState(categoryFilter: workCategory),
      );

      expect(result.length, 2);
      // Team Planning (Jan 17) should be before Morning Meeting (Jan 15)
      expect(result[0].from.isAfter(result[1].from), true);
    });

    test('filtering does not modify original list', () {
      final originalLength = testNotes.length;
      final originalFirstTitle = testNotes.first.title;

      filterNotes(testNotes, const NoteSearchState(query: 'meeting'));

      expect(testNotes.length, originalLength);
      expect(testNotes.first.title, originalFirstTitle);
    });

    test('empty notes list returns empty result', () {
      final result = filterNotes([], const NoteSearchState(query: 'test'));

      expect(result, isEmpty);
    });

    test('date filter works at day boundaries', () {
      final earlyMorning = Note(
        title: 'Early Meeting',
        description: 'Very early',
        from: DateTime(2026, 1, 15, 0, 30),
        to: DateTime(2026, 1, 15, 1, 30),
        noteCategory: workCategory,
      );

      final lateNight = Note(
        title: 'Late Work',
        description: 'Working late',
        from: DateTime(2026, 1, 15, 23, 30),
        to: DateTime(2026, 1, 16, 0, 30),
        noteCategory: workCategory,
      );

      final notes = [earlyMorning, lateNight];

      final result = filterNotes(
        notes,
        NoteSearchState(
          dateFrom: DateTime(2026, 1, 15),
          dateTo: DateTime(2026, 1, 15),
        ),
      );

      expect(result.length, 2);
    });
  });
}
