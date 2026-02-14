import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiaryDay', () {
    DiaryDay createSampleDiaryDay() {
      return DiaryDay(
        day: DateTime(2024, 3, 15),
        ratings: [
          DayRating(dayRating: DayRatings.social, score: 4),
          DayRating(dayRating: DayRatings.productivity, score: 3),
          DayRating(dayRating: DayRatings.sport, score: 5),
          DayRating(dayRating: DayRatings.food, score: 2),
        ],
      );
    }

    group('construction', () {
      test('creates with required fields', () {
        final day = DiaryDay(
          day: DateTime(2024, 3, 15),
          ratings: [DayRating(dayRating: DayRatings.social, score: 3)],
        );
        expect(day.day, DateTime(2024, 3, 15));
        expect(day.ratings.length, 1);
        expect(day.notes, isEmpty);
      });

      test('fromEmpty creates valid empty diary day', () {
        final day = DiaryDay.fromEmpty();
        expect(day.ratings, isEmpty);
        expect(day.notes, isEmpty);
        expect(day.day, isNotNull);
      });
    });

    group('overallScore', () {
      test('sums all rating scores correctly', () {
        final day = createSampleDiaryDay();
        expect(day.overallScore, 4 + 3 + 5 + 2); // 14
      });

      test('is 0 for empty ratings', () {
        final day = DiaryDay(day: DateTime(2024, 1, 1), ratings: []);
        expect(day.overallScore, 0);
      });

      test('handles single rating', () {
        final day = DiaryDay(
          day: DateTime(2024, 1, 1),
          ratings: [DayRating(dayRating: DayRatings.social, score: 5)],
        );
        expect(day.overallScore, 5);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleDiaryDay();
        final map = original.toMap();
        final restored = DiaryDay.fromMap(map);

        expect(Utils.toDate(restored.day), Utils.toDate(original.day));
        expect(restored.ratings.length, original.ratings.length);
        for (var i = 0; i < original.ratings.length; i++) {
          expect(restored.ratings[i].dayRating, original.ratings[i].dayRating);
          expect(restored.ratings[i].score, original.ratings[i].score);
        }
      });

      test('round-trip with notes', () {
        final original = createSampleDiaryDay();
        original.notes = [
          Note(
            title: 'Test Note',
            description: 'A test',
            from: DateTime(2024, 3, 15, 10, 0),
            to: DateTime(2024, 3, 15, 11, 0),
            noteCategory: availableNoteCategories.first,
          ),
        ];

        final map = original.toMap();
        final restored = DiaryDay.fromMap(map);

        expect(restored.notes.length, 1);
        expect(restored.notes.first.title, 'Test Note');
      });

      test('map contains correct keys', () {
        final day = createSampleDiaryDay();
        final map = day.toMap();

        expect(map, contains('day'));
        expect(map, contains('ratings'));
        expect(map, contains('notes'));
        expect(map['ratings'], isA<List>());
        expect(map['notes'], isA<List>());
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip with JSON-encoded ratings', () {
        final original = createSampleDiaryDay();
        final localDbMap = original.toLocalDbMap(original);

        expect(localDbMap['day'], Utils.toDate(original.day));
        expect(localDbMap['ratings'], isA<String>());

        // Verify the JSON-encoded ratings are valid
        final ratingsJson = jsonDecode(localDbMap['ratings']);
        expect(ratingsJson, isA<List>());
        expect(ratingsJson.length, original.ratings.length);

        // Round-trip through fromLocalDbMap
        final restored = DiaryDay.fromLocalDbMap(localDbMap);
        expect(restored.ratings.length, original.ratings.length);
        for (var i = 0; i < original.ratings.length; i++) {
          expect(restored.ratings[i].dayRating, original.ratings[i].dayRating);
          expect(restored.ratings[i].score, original.ratings[i].score);
        }
      });
    });

    group('getId', () {
      test('returns ISO date string (YYYY-MM-DD)', () {
        final day = DiaryDay(
          day: DateTime(2024, 3, 15),
          ratings: [],
        );
        expect(day.getId(), '2024-03-15');
      });

      test('pads single-digit months and days', () {
        final day = DiaryDay(
          day: DateTime(2024, 1, 5),
          ratings: [],
        );
        expect(day.getId(), '2024-01-05');
      });
    });
  });
}
