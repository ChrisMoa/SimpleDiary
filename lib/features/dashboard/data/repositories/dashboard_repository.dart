import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/streak_data.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';

/// Repository for dashboard data operations
class DashboardRepository {
  /// Calculate current streak from diary days
  StreakData calculateStreak(List<DiaryDay> diaryDays) {
    if (diaryDays.isEmpty) {
      return StreakData.empty();
    }

    // Sort diary days by date descending
    final sortedDays = List<DiaryDay>.from(diaryDays)
      ..sort((a, b) => b.day.compareTo(a.day));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastEntryDate;
    List<DateTime> streakDates = [];

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if today or yesterday has an entry
    bool isActive = false;
    if (sortedDays.isNotEmpty) {
      final lastDay = sortedDays.first.day;
      isActive = Utils.isSameDay(lastDay, today) ||
          Utils.isSameDay(lastDay, yesterday);
      lastEntryDate = lastDay;
    }

    // Calculate current streak
    DateTime expectedDate = today;
    for (var diaryDay in sortedDays) {
      if (Utils.isSameDay(diaryDay.day, expectedDate) ||
          Utils.isSameDay(diaryDay.day, expectedDate.subtract(const Duration(days: 1)))) {
        currentStreak++;
        streakDates.add(diaryDay.day);
        expectedDate = diaryDay.day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate longest streak
    tempStreak = 1;
    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i - 1].day.difference(sortedDays[i].day).inDays;
      if (diff == 1) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
    longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;

    LogWrapper.logger.d('Calculated streak: current=$currentStreak, longest=$longestStreak');

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastEntryDate: lastEntryDate,
      streakDates: streakDates,
      isActive: isActive,
    );
  }

  /// Check if today has been logged
  bool isTodayLogged(List<DiaryDay> diaryDays, DateTime today) {
    return diaryDays.any((day) => Utils.isSameDay(day.day, today));
  }

  /// Calculate week statistics
  WeekStats calculateWeekStats(List<DiaryDay> diaryDays, List<Note> notes) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekDays = diaryDays.where((day) =>
        day.day.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        day.day.isBefore(weekEnd.add(const Duration(days: 1)))).toList();

    if (weekDays.isEmpty) {
      return WeekStats(
        averageScore: 0,
        completedDays: 0,
        categoryAverages: {},
        dailyScores: [],
      );
    }

    // Calculate average score
    double totalScore = 0;
    Map<String, double> categoryTotals = {};
    Map<String, int> categoryCounts = {};

    for (var day in weekDays) {
      totalScore += day.overallScore;
      for (var rating in day.ratings) {
        final category = rating.dayRating.name;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + rating.score;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }

    final averageScore = weekDays.isNotEmpty ? totalScore / weekDays.length : 0;

    // Calculate category averages
    Map<String, double> categoryAverages = {};
    categoryTotals.forEach((category, total) {
      categoryAverages[category] = total / (categoryCounts[category] ?? 1);
    });

    // Create daily scores
    List<DayScore> dailyScores = [];
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayData = weekDays.where((d) => Utils.isSameDay(d.day, date)).firstOrNull;

      if (dayData != null) {
        Map<String, int> categoryScores = {};
        for (var rating in dayData.ratings) {
          categoryScores[rating.dayRating.name] = rating.score;
        }

        final dayNotes = notes.where((note) => Utils.isSameDay(note.from, date)).length;

        dailyScores.add(DayScore(
          date: date,
          totalScore: dayData.overallScore,
          categoryScores: categoryScores,
          noteCount: dayNotes,
          isComplete: dayData.ratings.isNotEmpty,
        ));
      } else {
        dailyScores.add(DayScore(
          date: date,
          totalScore: 0,
          categoryScores: {},
          noteCount: 0,
          isComplete: false,
        ));
      }
    }

    LogWrapper.logger.d('Week stats: avg=$averageScore, completed=${weekDays.length}');

    return WeekStats(
      averageScore: averageScore.toDouble(),
      completedDays: weekDays.length,
      categoryAverages: categoryAverages,
      dailyScores: dailyScores,
    );
  }

  /// Calculate monthly trend
  Map<String, double> calculateMonthlyTrend(List<DiaryDay> diaryDays) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final monthDays = diaryDays.where((day) =>
        day.day.year == now.year && day.day.month == now.month).toList();

    Map<String, double> trend = {};
    if (monthDays.isEmpty) return trend;

    // Calculate weekly averages for the month
    for (int week = 0; week < 5; week++) {
      final weekStart = monthStart.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekDays = monthDays.where((day) =>
          day.day.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          day.day.isBefore(weekEnd.add(const Duration(days: 1)))).toList();

      if (weekDays.isNotEmpty) {
        double weekTotal = 0;
        for (var day in weekDays) {
          weekTotal += day.overallScore;
        }
        trend['week_${week + 1}'] = weekTotal / weekDays.length;
      }
    }

    return trend;
  }

  /// Extract top activities from notes
  List<String> extractTopActivities(List<Note> notes) {
    if (notes.isEmpty) return [];

    Map<String, int> activityCounts = {};
    for (var note in notes) {
      final category = note.noteCategory.title;
      activityCounts[category] = (activityCounts[category] ?? 0) + 1;
    }

    final sorted = activityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Generate dashboard statistics
  DashboardStats generateDashboardStats(
    List<DiaryDay> diaryDays,
    List<Note> notes,
  ) {
    final today = DateTime.now();
    final streak = calculateStreak(diaryDays);
    final todayLogged = isTodayLogged(diaryDays, today);
    final weekStats = calculateWeekStats(diaryDays, notes);
    final monthlyTrend = calculateMonthlyTrend(diaryDays);
    final topActivities = extractTopActivities(notes);
    final insights = _generateInsights(streak, weekStats, todayLogged);

    LogWrapper.logger.i('Generated dashboard stats');

    return DashboardStats(
      currentStreak: streak.currentStreak,
      todayLogged: todayLogged,
      weekStats: weekStats,
      monthlyTrend: monthlyTrend,
      topActivities: topActivities,
      insights: insights,
    );
  }

  /// Generate insights based on data
  /// Titles and descriptions use English keys/fallbacks.
  /// The presentation layer should resolve localized strings
  /// based on InsightType and dynamicData.
  List<Insight> _generateInsights(
    StreakData streak,
    WeekStats weekStats,
    bool todayLogged,
  ) {
    List<Insight> insights = [];

    // Streak milestone
    if (streak.isMilestone) {
      insights.add(Insight(
        title: 'Streak Milestone',
        description: 'You reached an important milestone!',
        type: InsightType.milestone,
        icon: '🎉',
        dynamicData: streak.currentStreak.toString(),
      ));
    }

    // Perfect week
    if (weekStats.completedDays == 7) {
      insights.add(Insight(
        title: 'Perfect Week',
        description: 'You logged every day this week!',
        type: InsightType.achievement,
        icon: '⭐',
      ));
    }

    // Today not logged reminder
    if (!todayLogged) {
      insights.add(Insight(
        title: 'Not Recorded Today',
        description: 'Don\'t forget to rate your day!',
        type: InsightType.suggestion,
        icon: '⏰',
      ));
    }

    // Best category
    if (weekStats.categoryAverages.isNotEmpty) {
      final bestCategory = weekStats.categoryAverages.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(Insight(
        title: 'Best Category',
        description: 'Your best category this week: ${bestCategory.key}',
        type: InsightType.improvement,
        icon: '📊',
        dynamicData: bestCategory.key,
      ));
    }

    return insights;
  }
}
