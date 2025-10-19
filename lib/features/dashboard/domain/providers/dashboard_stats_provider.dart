import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:day_tracker/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for dashboard repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Provider for dashboard statistics
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  LogWrapper.logger.d('Loading dashboard statistics');

  final repository = ref.watch(dashboardRepositoryProvider);
  final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final notes = ref.watch(notesLocalDataProvider);

  return repository.generateDashboardStats(diaryDays, notes);
});

/// Provider for refreshing dashboard
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);
