import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/weekly_review/data/repositories/weekly_review_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WeeklyReviewRepository repository;

  setUp(() {
    repository = WeeklyReviewRepository();
  });

  DiaryDay createDiaryDay(DateTime date, {
    int socialScore = 4,
    int productivityScore = 3,
    bool isFavorite = false,
    EnhancedDayRating? enhancedRating,
  }) {
    return DiaryDay(
      day: date,
      ratings: [
        DayRating(dayRating: DayRatings.social, score: socialScore),
        DayRating(dayRating: DayRatings.productivity, score: productivityScore),
      ],
      isFavorite: isFavorite,
      enhancedRating: enhancedRating,
    );
  }

  Note createNote(DateTime date, {String title = 'Test', String category = 'Work', bool isFavorite = false}) {
    final note = Note(
      title: title,
      description: '',
      from: date,
      to: date.add(const Duration(hours: 1)),
      noteCategory: NoteCategory.fromString(category),
    );
    note.isFavorite = isFavorite;
    return note;
  }

  group('generateReview', () {
    test('generates review with correct week boundaries', () {
      // Week 10 of 2026: March 2 (Mon) – March 8 (Sun)
      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: [],
        allNotes: [],
        currentStreak: 5,
      );

      expect(review.year, 2026);
      expect(review.weekNumber, 10);
      expect(review.weekStart.weekday, DateTime.monday);
      expect(review.weekEnd.weekday, DateTime.sunday);
      expect(review.currentStreak, 5);
    });

    test('returns empty averages for empty data', () {
      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: [],
        allNotes: [],
        currentStreak: 0,
      );

      expect(review.averageScore, 0.0);
      expect(review.completedDays, 0);
      expect(review.dailyScores.length, 7);
      expect(review.dailyScores.every((d) => d['isComplete'] == false), true);
    });

    test('calculates correct average score', () {
      final days = [
        createDiaryDay(DateTime(2026, 3, 2), socialScore: 5, productivityScore: 5), // 10
        createDiaryDay(DateTime(2026, 3, 3), socialScore: 3, productivityScore: 3), // 6
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 2,
      );

      expect(review.completedDays, 2);
      expect(review.averageScore, 8.0); // (10 + 6) / 2
    });

    test('only includes days within the week range', () {
      final days = [
        createDiaryDay(DateTime(2026, 3, 1)), // Sunday before (week 9)
        createDiaryDay(DateTime(2026, 3, 2)), // Monday (week 10)
        createDiaryDay(DateTime(2026, 3, 8)), // Sunday (week 10)
        createDiaryDay(DateTime(2026, 3, 9)), // Monday after (week 11)
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      expect(review.completedDays, 2);
    });

    test('builds 7 daily scores including empty days', () {
      final days = [
        createDiaryDay(DateTime(2026, 3, 2), socialScore: 5, productivityScore: 5),
        createDiaryDay(DateTime(2026, 3, 5), socialScore: 3, productivityScore: 3),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final scores = review.dailyScores;
      expect(scores.length, 7);
      expect(scores[0]['isComplete'], true); // Monday
      expect(scores[0]['score'], 10);
      expect(scores[1]['isComplete'], false); // Tuesday
      expect(scores[3]['isComplete'], true); // Thursday
      expect(scores[3]['score'], 6);
    });

    test('calculates category averages', () {
      final days = [
        createDiaryDay(DateTime(2026, 3, 2), socialScore: 4, productivityScore: 2),
        createDiaryDay(DateTime(2026, 3, 3), socialScore: 2, productivityScore: 4),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final avgs = review.categoryAverages;
      expect(avgs['social'], 3.0);
      expect(avgs['productivity'], 3.0);
    });

    test('counts notes per day', () {
      final notes = [
        createNote(DateTime(2026, 3, 2), title: 'Note 1'),
        createNote(DateTime(2026, 3, 2), title: 'Note 2'),
        createNote(DateTime(2026, 3, 4), title: 'Note 3'),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: [],
        allNotes: notes,
        currentStreak: 0,
      );

      final scores = review.dailyScores;
      expect(scores[0]['noteCount'], 2); // Monday: 2 notes
      expect(scores[1]['noteCount'], 0); // Tuesday: 0 notes
      expect(scores[2]['noteCount'], 1); // Wednesday: 1 note
    });
  });

  group('PERMA+ averages', () {
    test('calculates averages from enhanced ratings', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            wellbeing: const WellbeingRating(mood: 4, energy: 3, connection: 5),
          ),
        ),
        createDiaryDay(
          DateTime(2026, 3, 3),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 3),
            wellbeing: const WellbeingRating(mood: 2, energy: 5, connection: 3),
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final perma = review.permaAverages;
      expect(perma['mood'], 3.0); // (4 + 2) / 2
      expect(perma['energy'], 4.0); // (3 + 5) / 2
      expect(perma['connection'], 4.0); // (5 + 3) / 2
    });

    test('skips zero-rated dimensions', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            wellbeing: const WellbeingRating(mood: 4, energy: 0),
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final perma = review.permaAverages;
      expect(perma['mood'], 4.0);
      expect(perma.containsKey('energy'), false); // skipped (0)
    });

    test('empty when no enhanced ratings', () {
      final days = [createDiaryDay(DateTime(2026, 3, 2))];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      expect(review.permaAverages, isEmpty);
    });
  });

  group('emotions', () {
    test('counts top emotions sorted by frequency', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            emotions: const [
              EmotionEntry(emotion: EmotionType.joy, intensity: 3),
              EmotionEntry(emotion: EmotionType.gratitude, intensity: 2),
            ],
          ),
        ),
        createDiaryDay(
          DateTime(2026, 3, 3),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 3),
            emotions: const [
              EmotionEntry(emotion: EmotionType.joy, intensity: 2),
              EmotionEntry(emotion: EmotionType.anxiety, intensity: 1),
            ],
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final emotions = review.topEmotions;
      expect(emotions.first['emotion'], 'joy');
      expect(emotions.first['count'], 2);
      expect(emotions.length, 3);
    });

    test('limits to top 5 emotions', () {
      final manyEmotions = List.generate(8, (i) =>
        EmotionEntry(emotion: EmotionType.values[i], intensity: 1),
      );
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            emotions: manyEmotions,
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      expect(review.topEmotions.length, lessThanOrEqualTo(5));
    });
  });

  group('context summary', () {
    test('calculates averages for context factors', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            context: const ContextualFactors(
              sleepHours: 7.0,
              sleepQuality: 4,
              exercised: true,
              stressLevel: 2,
            ),
          ),
        ),
        createDiaryDay(
          DateTime(2026, 3, 3),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 3),
            context: const ContextualFactors(
              sleepHours: 8.0,
              sleepQuality: 3,
              exercised: false,
              stressLevel: 4,
            ),
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final ctx = review.contextSummary;
      expect(ctx['avgSleep'], 7.5);
      expect(ctx['avgSleepQuality'], 3.5);
      expect(ctx['exerciseDays'], 1);
      expect(ctx['avgStress'], 3.0);
    });

    test('handles null context factors', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final ctx = review.contextSummary;
      expect(ctx['avgSleep'], isNull);
      expect(ctx['exerciseDays'], 0);
      expect(ctx['avgStress'], isNull);
    });
  });

  group('highlights', () {
    test('collects favorite days and notes', () {
      final days = [
        createDiaryDay(DateTime(2026, 3, 2), isFavorite: true),
        createDiaryDay(DateTime(2026, 3, 3), isFavorite: false),
      ];
      final notes = [
        createNote(DateTime(2026, 3, 2), title: 'Great run', category: 'Gym', isFavorite: true),
        createNote(DateTime(2026, 3, 3), title: 'Normal day', isFavorite: false),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: notes,
        currentStreak: 0,
      );

      final h = review.highlights;
      expect((h['favoriteDays'] as List).length, 1);
      expect((h['favoriteNotes'] as List).length, 1);
      expect((h['favoriteNotes'] as List).first['title'], 'Great run');
    });

    test('empty when no favorites', () {
      final days = [createDiaryDay(DateTime(2026, 3, 2))];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final h = review.highlights;
      expect((h['favoriteDays'] as List), isEmpty);
      expect((h['favoriteNotes'] as List), isEmpty);
    });
  });

  group('mood trend', () {
    test('extracts mood positions', () {
      final days = [
        createDiaryDay(
          DateTime(2026, 3, 2),
          enhancedRating: EnhancedDayRating(
            date: DateTime(2026, 3, 2),
            quickMood: MoodPosition(
              valence: 0.5,
              arousal: 0.3,
              timestamp: DateTime(2026, 3, 2, 20, 0),
            ),
          ),
        ),
      ];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      final trend = review.moodTrend;
      expect(trend.length, 1);
      expect(trend.first['valence'], 0.5);
      expect(trend.first['arousal'], 0.3);
    });

    test('empty when no quick mood data', () {
      final days = [createDiaryDay(DateTime(2026, 3, 2))];

      final review = repository.generateReview(
        year: 2026,
        weekNumber: 10,
        allDiaryDays: days,
        allNotes: [],
        currentStreak: 0,
      );

      expect(review.moodTrend, isEmpty);
    });
  });

  group('previousWeek', () {
    test('returns valid year and week', () {
      final (year, week) = WeeklyReviewRepository.previousWeek();
      expect(year, greaterThan(2020));
      expect(week, greaterThanOrEqualTo(1));
      expect(week, lessThanOrEqualTo(53));
    });
  });
}
