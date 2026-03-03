import 'package:day_tracker/core/database/db_provider_factory.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:day_tracker/features/weekly_review/data/repositories/weekly_review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DB-backed provider for persisted weekly reviews.
final weeklyReviewLocalDbProvider = createDbProvider<WeeklyReviewData>(
  tableName: WeeklyReviewData.tableName,
  columns: WeeklyReviewData.columns,
  fromMap: WeeklyReviewData.fromDbMap,
  migrations: WeeklyReviewData.migrations,
);

/// Repository provider (stateless computation).
final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) {
  return WeeklyReviewRepository();
});

/// All persisted reviews sorted by week descending.
final allWeeklyReviewsProvider = Provider<List<WeeklyReviewData>>((ref) {
  final reviews = ref.watch(weeklyReviewLocalDbProvider);
  final sorted = List<WeeklyReviewData>.from(reviews)
    ..sort((a, b) {
      final yearCmp = b.year.compareTo(a.year);
      if (yearCmp != 0) return yearCmp;
      return b.weekNumber.compareTo(a.weekNumber);
    });
  return sorted;
});

/// Check if a review already exists for a given week.
final hasReviewForWeekProvider =
    Provider.family<bool, ({int year, int week})>((ref, params) {
  final reviews = ref.watch(weeklyReviewLocalDbProvider);
  return reviews.any(
    (r) => r.year == params.year && r.weekNumber == params.week,
  );
});

/// Find an existing review for a given week, or null.
final reviewForWeekProvider =
    Provider.family<WeeklyReviewData?, ({int year, int week})>((ref, params) {
  final reviews = ref.watch(weeklyReviewLocalDbProvider);
  return reviews
      .where((r) => r.year == params.year && r.weekNumber == params.week)
      .firstOrNull;
});

/// Generate a review for a given week, persist it, and return it.
///
/// If a review already exists for that week, returns the existing one.
final generateWeeklyReviewProvider =
    FutureProvider.family<WeeklyReviewData, ({int year, int week})>(
  (ref, params) async {
    // Check for existing review first
    final existing = ref.read(reviewForWeekProvider(params));
    if (existing != null) return existing;

    LogWrapper.logger.i(
      'Generating weekly review for week ${params.week}/${params.year}',
    );

    final repository = ref.read(weeklyReviewRepositoryProvider);
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);
    final notes = ref.read(notesLocalDataProvider);
    final streak = ref.read(currentStreakProvider);

    final review = repository.generateReview(
      year: params.year,
      weekNumber: params.week,
      allDiaryDays: diaryDays,
      allNotes: notes,
      currentStreak: streak,
    );

    // Persist
    await ref.read(weeklyReviewLocalDbProvider.notifier).addElement(review);

    LogWrapper.logger.i('Weekly review generated and persisted: ${review.weekLabel}');
    return review;
  },
);
