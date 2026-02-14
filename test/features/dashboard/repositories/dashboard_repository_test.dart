import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DashboardRepository repository;

  setUp(() {
    repository = DashboardRepository();
  });

  /// Helper: create a DiaryDay for a specific date with ratings
  DiaryDay createDiaryDay(DateTime date, {int socialScore = 3, int productivityScore = 3}) {
    return DiaryDay(
      day: date,
      ratings: [
        DayRating(dayRating: DayRatings.social, score: socialScore),
        DayRating(dayRating: DayRatings.productivity, score: productivityScore),
        DayRating(dayRating: DayRatings.sport, score: 3),
        DayRating(dayRating: DayRatings.food, score: 3),
      ],
    );
  }

  /// Helper: create a list of consecutive diary days ending today
  List<DiaryDay> createConsecutiveDays(int count, {DateTime? endDate}) {
    final end = endDate ?? DateTime.now();
    return List.generate(count, (i) {
      return createDiaryDay(end.subtract(Duration(days: i)));
    });
  }

  group('DashboardRepository', () {
    group('calculateStreak', () {
      test('empty diary days returns empty streak', () {
        final streak = repository.calculateStreak([]);
        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.isActive, false);
        expect(streak.lastEntryDate, isNull);
        expect(streak.streakDates, isEmpty);
      });

      test('single day today returns streak of 1', () {
        final today = DateTime.now();
        final days = [createDiaryDay(today)];
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 1);
        expect(streak.isActive, true);
      });

      test('single day yesterday returns streak of 1', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final days = [createDiaryDay(yesterday)];
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 1);
        expect(streak.isActive, true);
      });

      test('consecutive days from today count as streak', () {
        final days = createConsecutiveDays(5);
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 5);
        expect(streak.isActive, true);
        expect(streak.streakDates.length, 5);
      });

      test('gap of 2+ days breaks current streak', () {
        final today = DateTime.now();
        final days = [
          createDiaryDay(today),
          createDiaryDay(today.subtract(const Duration(days: 1))),
          // gap: day -2 and day -3 missing (2-day gap)
          createDiaryDay(today.subtract(const Duration(days: 4))),
          createDiaryDay(today.subtract(const Duration(days: 5))),
        ];
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 2); // only today + yesterday
      });

      test('single-day gap is tolerated by streak algorithm', () {
        // The algorithm checks expectedDate AND expectedDate-1,
        // so a single missing day does not break the streak
        final today = DateTime.now();
        final days = [
          createDiaryDay(today),
          createDiaryDay(today.subtract(const Duration(days: 1))),
          // day -2 missing (single-day gap)
          createDiaryDay(today.subtract(const Duration(days: 3))),
        ];
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 3); // all 3 count due to tolerance
      });

      test('longest streak is tracked separately from current', () {
        final today = DateTime.now();
        final days = [
          createDiaryDay(today),
          // 2-day gap (day -1 and -2 missing)
          createDiaryDay(today.subtract(const Duration(days: 4))),
          createDiaryDay(today.subtract(const Duration(days: 5))),
          createDiaryDay(today.subtract(const Duration(days: 6))),
        ];
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 1); // only today
        expect(streak.longestStreak, greaterThanOrEqualTo(3)); // 3 consecutive in the past
      });

      test('old entry with no recent activity is not active', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 10));
        final days = [createDiaryDay(oldDate)];
        final streak = repository.calculateStreak(days);

        expect(streak.isActive, false);
        expect(streak.currentStreak, greaterThanOrEqualTo(0));
      });

      test('7-day streak is a milestone', () {
        final days = createConsecutiveDays(7);
        final streak = repository.calculateStreak(days);

        expect(streak.currentStreak, 7);
        expect(streak.isMilestone, true);
        expect(streak.milestoneText, contains('Woche'));
      });

      test('lastEntryDate is the most recent day', () {
        final today = DateTime.now();
        final days = createConsecutiveDays(3, endDate: today);
        final streak = repository.calculateStreak(days);

        expect(streak.lastEntryDate, isNotNull);
        expect(streak.lastEntryDate!.year, today.year);
        expect(streak.lastEntryDate!.month, today.month);
        expect(streak.lastEntryDate!.day, today.day);
      });
    });

    group('isTodayLogged', () {
      test('returns true when today is logged', () {
        final today = DateTime.now();
        final days = [createDiaryDay(today)];
        expect(repository.isTodayLogged(days, today), true);
      });

      test('returns false when today is not logged', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final days = [createDiaryDay(yesterday)];
        expect(repository.isTodayLogged(days, today), false);
      });

      test('returns false for empty list', () {
        expect(repository.isTodayLogged([], DateTime.now()), false);
      });
    });

    group('calculateWeekStats', () {
      test('empty diary days returns zero stats', () {
        final stats = repository.calculateWeekStats([], []);
        expect(stats.averageScore, 0);
        expect(stats.completedDays, 0);
        expect(stats.categoryAverages, isEmpty);
        expect(stats.dailyScores, isEmpty);
      });

      test('calculates average score for week days', () {
        final now = DateTime.now();
        // Create diary days for this week
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = [
          createDiaryDay(weekStart, socialScore: 5, productivityScore: 5),
          createDiaryDay(weekStart.add(const Duration(days: 1)),
              socialScore: 1, productivityScore: 1),
        ];
        final stats = repository.calculateWeekStats(days, []);

        expect(stats.completedDays, 2);
        expect(stats.averageScore, greaterThan(0));
        expect(stats.dailyScores.length, 7); // always 7 days in a week
      });

      test('category averages are calculated correctly', () {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = [
          createDiaryDay(weekStart, socialScore: 5, productivityScore: 3),
          createDiaryDay(weekStart.add(const Duration(days: 1)),
              socialScore: 3, productivityScore: 5),
        ];
        final stats = repository.calculateWeekStats(days, []);

        expect(stats.categoryAverages, isNotEmpty);
        expect(stats.categoryAverages['social'], 4.0); // (5+3)/2
        expect(stats.categoryAverages['productivity'], 4.0); // (3+5)/2
      });

      test('daily scores include note counts', () {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = [createDiaryDay(weekStart)];
        final notes = [
          Note(
            title: 'Test',
            description: '',
            from: weekStart.copyWith(hour: 10),
            to: weekStart.copyWith(hour: 11),
            noteCategory: availableNoteCategories.first,
          ),
          Note(
            title: 'Test 2',
            description: '',
            from: weekStart.copyWith(hour: 12),
            to: weekStart.copyWith(hour: 13),
            noteCategory: availableNoteCategories.first,
          ),
        ];
        final stats = repository.calculateWeekStats(days, notes);

        // The first day should have noteCount of 2
        final firstDay = stats.dailyScores
            .where((ds) =>
                ds.date.year == weekStart.year &&
                ds.date.month == weekStart.month &&
                ds.date.day == weekStart.day)
            .firstOrNull;
        expect(firstDay, isNotNull);
        expect(firstDay!.noteCount, 2);
        expect(firstDay.isComplete, true);
      });

      test('uncompleted days have isComplete false and zero scores', () {
        // When there ARE diary days but not all 7, the missing ones are empty
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = [createDiaryDay(weekStart)];
        final statsWithData = repository.calculateWeekStats(days, []);

        // There should be 7 daily scores
        expect(statsWithData.dailyScores.length, 7);
        // At least some should be incomplete
        final incompleteDays =
            statsWithData.dailyScores.where((ds) => !ds.isComplete);
        expect(incompleteDays.length, greaterThanOrEqualTo(6));
      });
    });

    group('calculateMonthlyTrend', () {
      test('empty diary days returns empty trend', () {
        final trend = repository.calculateMonthlyTrend([]);
        expect(trend, isEmpty);
      });

      test('groups entries by week within current month', () {
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final days = [
          createDiaryDay(monthStart.add(const Duration(days: 0))),
          createDiaryDay(monthStart.add(const Duration(days: 1))),
          createDiaryDay(monthStart.add(const Duration(days: 7))),
          createDiaryDay(monthStart.add(const Duration(days: 8))),
        ];
        // Only include days that are in the current month
        final validDays = days
            .where((d) =>
                d.day.month == now.month &&
                d.day.year == now.year &&
                !d.day.isAfter(now))
            .toList();

        if (validDays.isNotEmpty) {
          final trend = repository.calculateMonthlyTrend(validDays);
          expect(trend, isNotEmpty);
          // Should contain 'week_X' keys
          expect(trend.keys.first, startsWith('week_'));
        }
      });

      test('does not include days from other months', () {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 15);
        final days = [createDiaryDay(lastMonth)];
        final trend = repository.calculateMonthlyTrend(days);
        expect(trend, isEmpty);
      });
    });

    group('extractTopActivities', () {
      test('empty notes returns empty list', () {
        expect(repository.extractTopActivities([]), isEmpty);
      });

      test('returns categories sorted by frequency', () {
        final notes = [
          Note(title: 'A', description: '', from: DateTime.now(),
              to: DateTime.now().add(const Duration(hours: 1)),
              noteCategory: availableNoteCategories[0]), // Work
          Note(title: 'B', description: '', from: DateTime.now(),
              to: DateTime.now().add(const Duration(hours: 1)),
              noteCategory: availableNoteCategories[0]), // Work
          Note(title: 'C', description: '', from: DateTime.now(),
              to: DateTime.now().add(const Duration(hours: 1)),
              noteCategory: availableNoteCategories[0]), // Work
          Note(title: 'D', description: '', from: DateTime.now(),
              to: DateTime.now().add(const Duration(hours: 1)),
              noteCategory: availableNoteCategories[1]), // Leisure
          Note(title: 'E', description: '', from: DateTime.now(),
              to: DateTime.now().add(const Duration(hours: 1)),
              noteCategory: availableNoteCategories[2]), // Food
        ];

        final top = repository.extractTopActivities(notes);
        expect(top.first, 'Work'); // most frequent
        expect(top, contains('Leisure'));
        expect(top, contains('Food'));
      });

      test('returns at most 5 activities', () {
        final notes = List.generate(20, (i) {
          return Note(
            title: 'Note $i',
            description: '',
            from: DateTime.now(),
            to: DateTime.now().add(const Duration(hours: 1)),
            noteCategory: NoteCategory(
                title: 'Category ${i % 8}',
                color: const Color(0xFF000000)),
          );
        });

        final top = repository.extractTopActivities(notes);
        expect(top.length, lessThanOrEqualTo(5));
      });
    });

    group('_generateInsights (via generateDashboardStats)', () {
      test('includes today-not-logged suggestion when today is missing', () {
        // Use days from yesterday only
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final days = [createDiaryDay(yesterday)];
        final stats = repository.generateDashboardStats(days, []);

        final todayReminder = stats.insights
            .where((i) => i.type == InsightType.suggestion)
            .toList();
        expect(todayReminder, isNotEmpty);
      });

      test('includes perfect week achievement when 7 days completed', () {
        // Create 7 days for this week
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = List.generate(7, (i) {
          return createDiaryDay(weekStart.add(Duration(days: i)));
        });
        final stats = repository.generateDashboardStats(days, []);

        final perfectWeek = stats.insights
            .where((i) =>
                i.type == InsightType.achievement &&
                i.title.contains('Perfect'))
            .toList();
        expect(perfectWeek, isNotEmpty);
      });

      test('includes best category insight when data exists', () {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = [
          createDiaryDay(weekStart, socialScore: 5, productivityScore: 2),
        ];
        final stats = repository.generateDashboardStats(days, []);

        final bestCat = stats.insights
            .where((i) => i.type == InsightType.improvement)
            .toList();
        expect(bestCat, isNotEmpty);
      });

      test('includes milestone for 7-day streak', () {
        final days = createConsecutiveDays(7);
        final stats = repository.generateDashboardStats(days, []);

        final milestones = stats.insights
            .where((i) => i.type == InsightType.milestone)
            .toList();
        expect(milestones, isNotEmpty);
      });
    });

    group('generateDashboardStats', () {
      test('combines all calculations into DashboardStats', () {
        final now = DateTime.now();
        final days = createConsecutiveDays(3, endDate: now);
        final notes = [
          Note(
            title: 'Work',
            description: '',
            from: now.copyWith(hour: 9),
            to: now.copyWith(hour: 10),
            noteCategory: availableNoteCategories[0],
          ),
        ];

        final stats = repository.generateDashboardStats(days, notes);

        expect(stats.currentStreak, 3);
        expect(stats.todayLogged, true);
        expect(stats.weekStats, isNotNull);
        expect(stats.monthlyTrend, isNotNull);
        expect(stats.topActivities, isNotEmpty);
        expect(stats.insights, isNotEmpty);
        expect(stats.lastUpdated, isNotNull);
      });

      test('works with empty data', () {
        final stats = repository.generateDashboardStats([], []);

        expect(stats.currentStreak, 0);
        expect(stats.todayLogged, false);
        expect(stats.weekStats.completedDays, 0);
        expect(stats.monthlyTrend, isEmpty);
        expect(stats.topActivities, isEmpty);
      });
    });
  });
}
