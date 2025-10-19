import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for week overview
final weekOverviewProvider = FutureProvider<WeekStats>((ref) async {
  LogWrapper.logger.d('Loading week overview');

  final stats = await ref.watch(dashboardStatsProvider.future);
  return stats.weekStats;
});
