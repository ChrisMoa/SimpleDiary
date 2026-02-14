import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayRatings enum', () {
    group('stringToEnum', () {
      test('converts all valid strings', () {
        expect(stringToEnum('social'), DayRatings.social);
        expect(stringToEnum('productivity'), DayRatings.productivity);
        expect(stringToEnum('sport'), DayRatings.sport);
        expect(stringToEnum('food'), DayRatings.food);
      });

      test('throws on invalid string', () {
        expect(() => stringToEnum('invalid'), throwsArgumentError);
        expect(() => stringToEnum(''), throwsArgumentError);
        expect(() => stringToEnum('Social'), throwsArgumentError); // case-sensitive
      });
    });
  });

  group('DayRating', () {
    test('default score is -1', () {
      final rating = DayRating(dayRating: DayRatings.social);
      expect(rating.score, -1);
    });

    test('creates with custom score', () {
      final rating = DayRating(dayRating: DayRatings.sport, score: 4);
      expect(rating.dayRating, DayRatings.sport);
      expect(rating.score, 4);
    });

    group('toMap / fromMap', () {
      test('round-trip for all rating types', () {
        for (final ratingType in DayRatings.values) {
          final original = DayRating(dayRating: ratingType, score: 3);
          final map = original.toMap();
          final restored = DayRating.fromMap(map);

          expect(restored.dayRating, original.dayRating);
          expect(restored.score, original.score);
        }
      });

      test('map contains correct keys and values', () {
        final rating = DayRating(dayRating: DayRatings.productivity, score: 5);
        final map = rating.toMap();

        expect(map['dayRating'], 'productivity');
        expect(map['score'], 5);
      });
    });

    group('Firestore map conversion', () {
      test('toFirestoreMap produces correct structure', () {
        final rating = DayRating(dayRating: DayRatings.food, score: 2);
        final firestoreMap = rating.toFirestoreMap();

        expect(firestoreMap['fields']['dayRating']['stringValue'], 'food');
        expect(firestoreMap['fields']['score']['integerValue'], 2);
      });

      test('fromFirestoreMap parses Firestore REST format', () {
        // Firestore REST API stores integerValue as String
        final firestoreFields = {
          'dayRating': {'stringValue': 'social'},
          'score': {'integerValue': '4'},
        };
        final restored = DayRating.fromFirestoreMap(firestoreFields);

        expect(restored.dayRating, DayRatings.social);
        expect(restored.score, 4);
      });

      test('toFirestoreMap stores score as int (note: Firestore REST uses strings)', () {
        // This documents a known inconsistency: toFirestoreMap stores int,
        // but fromFirestoreMap expects String (standard Firestore REST format)
        final rating = DayRating(dayRating: DayRatings.social, score: 4);
        final firestoreMap = rating.toFirestoreMap();
        expect(firestoreMap['fields']['score']['integerValue'], 4);
      });
    });

    test('score can be mutated', () {
      final rating = DayRating(dayRating: DayRatings.sport, score: 1);
      rating.score = 5;
      expect(rating.score, 5);
    });
  });
}
