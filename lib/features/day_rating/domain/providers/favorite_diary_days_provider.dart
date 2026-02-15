import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that filters diary days to only favorites
final favoriteDiaryDaysProvider = Provider<List<DiaryDay>>((ref) {
  final diaryDays = ref.watch(diaryDayFullDataProvider);
  return diaryDays
      .where((day) => day.isFavorite)
      .toList()
    ..sort((a, b) => b.day.compareTo(a.day)); // Most recent first
});

/// Count of favorite diary days
final favoriteDiaryDaysCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteDiaryDaysProvider).length;
});
