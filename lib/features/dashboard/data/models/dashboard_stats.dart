import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';

/// Dashboard statistics model containing all key metrics
class DashboardStats {
  final int currentStreak;
  final bool todayLogged;
  final WeekStats weekStats;
  final Map<String, double> monthlyTrend;
  final List<String> topActivities;
  final List<Insight> insights;
  final DateTime lastUpdated;

  DashboardStats({
    required this.currentStreak,
    required this.todayLogged,
    required this.weekStats,
    required this.monthlyTrend,
    required this.topActivities,
    required this.insights,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  DashboardStats copyWith({
    int? currentStreak,
    bool? todayLogged,
    WeekStats? weekStats,
    Map<String, double>? monthlyTrend,
    List<String>? topActivities,
    List<Insight>? insights,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      currentStreak: currentStreak ?? this.currentStreak,
      todayLogged: todayLogged ?? this.todayLogged,
      weekStats: weekStats ?? this.weekStats,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      topActivities: topActivities ?? this.topActivities,
      insights: insights ?? this.insights,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
