import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/dashboard/data/models/streak_data.dart';
import 'package:day_tracker/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for streak data
final streakProvider = Provider<StreakData>((ref) {
  LogWrapper.logger.d('Loading streak data');

  final repository = ref.watch(dashboardRepositoryProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);

  return repository.calculateStreak(diaryDays);
});

/// State notifier for managing streak state
class StreakNotifier extends StateNotifier<StreakData> {
  final Ref ref;

  StreakNotifier(this.ref) : super(StreakData.empty()) {
    _loadStreak();
  }

  void _loadStreak() {
    final repository = ref.read(dashboardRepositoryProvider);
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);
    state = repository.calculateStreak(diaryDays);
  }

  void refresh() {
    _loadStreak();
  }
}

/// State notifier provider for streak
final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, StreakData>((ref) {
  return StreakNotifier(ref);
});
