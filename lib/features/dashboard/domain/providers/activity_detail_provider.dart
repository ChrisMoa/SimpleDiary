import 'package:day_tracker/features/dashboard/data/repositories/activity_detail_repository.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ActivityDetailRepository
final activityDetailRepositoryProvider = Provider<ActivityDetailRepository>((ref) {
  return ActivityDetailRepository();
});

/// Provider for top activity summaries (used in dashboard)
final topActivitySummariesProvider = Provider<List<ActivitySummary>>((ref) {
  final repository = ref.watch(activityDetailRepositoryProvider);
  final notes = ref.watch(notesLocalDataProvider);
  final categories = ref.watch(categoryLocalDataProvider);
  return repository.extractTopActivitySummaries(notes, categories);
});

/// Family provider for activity stats (used in detail page)
final activityStatsProvider =
    Provider.family<ActivityStats, String>((ref, activityName) {
  final repository = ref.watch(activityDetailRepositoryProvider);
  final notes = ref.watch(notesLocalDataProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  return repository.getActivityStats(
    activityName: activityName,
    notes: notes,
    diaryDays: diaryDays,
  );
});

/// Family provider for notes filtered by activity
final notesByActivityProvider =
    Provider.family<List<Note>, String>((ref, activityName) {
  final repository = ref.watch(activityDetailRepositoryProvider);
  final notes = ref.watch(notesLocalDataProvider);
  return repository.getNotesByActivity(activityName, notes);
});

/// Family provider for diary days associated with an activity
final daysByActivityProvider =
    Provider.family<List<DiaryDay>, String>((ref, activityName) {
  final repository = ref.watch(activityDetailRepositoryProvider);
  final notes = ref.watch(notesLocalDataProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  return repository.getDaysByActivity(activityName, notes, diaryDays);
});
