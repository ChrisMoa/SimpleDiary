import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for insights
final insightsProvider = FutureProvider<List<Insight>>((ref) async {
  LogWrapper.logger.d('Loading insights');

  final stats = await ref.watch(dashboardStatsProvider.future);
  return stats.insights;
});
