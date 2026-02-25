import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';

// ── Categories ───────────────────────────────────────────────────────────────

final workCategory = NoteCategory(title: 'Work', color: Colors.purple);
final leisureCategory = NoteCategory(title: 'Leisure', color: Colors.lightBlue);
final foodCategory = NoteCategory(title: 'Food', color: Colors.amber);

List<NoteCategory> get integrationTestCategories =>
    [workCategory, leisureCategory, foodCategory];

// ── Note Factory ─────────────────────────────────────────────────────────────

Note makeTestNote({
  String? id,
  String title = 'Test Note',
  String description = 'Test Description',
  required DateTime from,
  Duration duration = const Duration(hours: 1),
  NoteCategory? category,
  bool isFavorite = false,
  bool isAllDay = false,
}) {
  return Note(
    id: id,
    title: title,
    description: description,
    from: from,
    to: from.add(duration),
    noteCategory: category ?? workCategory,
    isFavorite: isFavorite,
    isAllDay: isAllDay,
  );
}

// ── Ratings ──────────────────────────────────────────────────────────────────

List<DayRating> get defaultRatings => [
      DayRating(dayRating: DayRatings.social, score: 4),
      DayRating(dayRating: DayRatings.productivity, score: 3),
      DayRating(dayRating: DayRatings.sport, score: 5),
      DayRating(dayRating: DayRatings.food, score: 4),
    ];

// ── DiaryDay Factory ─────────────────────────────────────────────────────────

DiaryDay makeTestDiaryDay({
  required DateTime day,
  List<DayRating>? ratings,
  List<Note>? notes,
  bool isFavorite = false,
  EnhancedDayRating? enhancedRating,
}) {
  final diaryDay = DiaryDay(
    day: day,
    ratings: ratings ?? defaultRatings,
    isFavorite: isFavorite,
    enhancedRating: enhancedRating,
  );
  diaryDay.notes = notes ?? [];
  return diaryDay;
}

// ── Dates ────────────────────────────────────────────────────────────────────

/// A fixed reference date for deterministic tests.
final referenceDate = DateTime(2026, 2, 20);

/// Creates a DateTime offset from [referenceDate] by [daysOffset].
DateTime dateAt(int daysOffset) =>
    referenceDate.add(Duration(days: daysOffset));
