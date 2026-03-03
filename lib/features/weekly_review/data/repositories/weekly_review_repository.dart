import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';

/// Pure computation class that aggregates diary data for a given ISO week
/// into a [WeeklyReviewData] snapshot.
class WeeklyReviewRepository {
  /// Generate a [WeeklyReviewData] for the given ISO [year]/[weekNumber].
  ///
  /// Filters [allDiaryDays] and [allNotes] to the Monday–Sunday range,
  /// then computes all aggregations.
  WeeklyReviewData generateReview({
    required int year,
    required int weekNumber,
    required List<DiaryDay> allDiaryDays,
    required List<Note> allNotes,
    required int currentStreak,
  }) {
    final weekStart = WeeklyReviewData.mondayOfWeek(year, weekNumber);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Filter data to this week
    final weekDays = allDiaryDays.where((d) => _isInWeek(d.day, weekStart, weekEnd)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    final weekNotes = allNotes.where((n) => _isInWeek(n.from, weekStart, weekEnd)).toList();

    // Calculate daily scores
    final dailyScores = _buildDailyScores(weekStart, weekDays, weekNotes);

    // Calculate averages
    final completedDays = weekDays.where((d) => d.ratings.isNotEmpty || (d.enhancedRating != null && d.enhancedRating!.wellbeing.totalScore > 0)).length;
    final averageScore = completedDays > 0
        ? weekDays.fold<double>(0, (sum, d) => sum + d.overallScore) / completedDays
        : 0.0;

    // Category averages (from legacy DayRating)
    final categoryAverages = _calculateCategoryAverages(weekDays);

    // PERMA+ averages (from EnhancedDayRating)
    final permaAverages = _calculatePermaAverages(weekDays);

    // Top emotions
    final topEmotions = _calculateTopEmotions(weekDays);

    // Context summary
    final contextSummary = _calculateContextSummary(weekDays);

    // Mood trend
    final moodTrend = _extractMoodTrend(weekDays);

    // Highlights (favorites)
    final highlights = _extractHighlights(weekDays, weekNotes);

    return WeeklyReviewData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      year: year,
      weekNumber: weekNumber,
      averageScore: averageScore,
      completedDays: completedDays,
      dailyScoresJson: jsonEncode(dailyScores),
      categoryAveragesJson: jsonEncode(categoryAverages),
      permaAveragesJson: jsonEncode(permaAverages),
      topEmotionsJson: jsonEncode(topEmotions),
      contextSummaryJson: jsonEncode(contextSummary),
      moodTrendJson: jsonEncode(moodTrend),
      highlightsJson: jsonEncode(highlights),
      currentStreak: currentStreak,
    );
  }

  /// Get the previous week's year and week number.
  static (int year, int week) previousWeek() {
    final now = DateTime.now();
    final lastSunday = now.subtract(Duration(days: now.weekday));
    final lastMonday = lastSunday.subtract(const Duration(days: 6));
    final weekNumber = WeeklyReviewData.isoWeekNumber(lastMonday);
    // If week crosses year boundary, use the year of the Monday
    return (lastMonday.year, weekNumber);
  }

  bool _isInWeek(DateTime date, DateTime weekStart, DateTime weekEnd) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endOnly = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  List<Map<String, dynamic>> _buildDailyScores(
    DateTime weekStart,
    List<DiaryDay> weekDays,
    List<Note> weekNotes,
  ) {
    final scores = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayData = weekDays.where((d) => Utils.isSameDay(d.day, date)).firstOrNull;
      final dayNotes = weekNotes.where((n) => Utils.isSameDay(n.from, date)).length;

      if (dayData != null) {
        final categoryScores = <String, int>{};
        for (var rating in dayData.ratings) {
          categoryScores[rating.dayRating.name] = rating.score;
        }
        scores.add({
          'date': Utils.toDate(date),
          'score': dayData.overallScore,
          'noteCount': dayNotes,
          'isComplete': true,
          'categoryScores': categoryScores,
        });
      } else {
        scores.add({
          'date': Utils.toDate(date),
          'score': 0,
          'noteCount': dayNotes,
          'isComplete': false,
          'categoryScores': <String, int>{},
        });
      }
    }
    return scores;
  }

  Map<String, double> _calculateCategoryAverages(List<DiaryDay> weekDays) {
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (var day in weekDays) {
      for (var rating in day.ratings) {
        final category = rating.dayRating.name;
        totals[category] = (totals[category] ?? 0) + rating.score;
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    return totals.map((k, v) => MapEntry(k, v / (counts[k] ?? 1)));
  }

  Map<String, double> _calculatePermaAverages(List<DiaryDay> weekDays) {
    final dimensions = ['mood', 'energy', 'connection', 'purpose', 'achievement', 'engagement'];
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (var day in weekDays) {
      final enhanced = day.enhancedRating;
      if (enhanced == null) continue;
      final w = enhanced.wellbeing;

      final values = {
        'mood': w.mood,
        'energy': w.energy,
        'connection': w.connection,
        'purpose': w.purpose,
        'achievement': w.achievement,
        'engagement': w.engagement,
      };

      for (var dim in dimensions) {
        final val = values[dim] ?? 0;
        if (val > 0) {
          totals[dim] = (totals[dim] ?? 0) + val;
          counts[dim] = (counts[dim] ?? 0) + 1;
        }
      }
    }

    return totals.map((k, v) => MapEntry(k, v / (counts[k] ?? 1)));
  }

  List<Map<String, dynamic>> _calculateTopEmotions(List<DiaryDay> weekDays) {
    final emotionCounts = <String, int>{};

    for (var day in weekDays) {
      final enhanced = day.enhancedRating;
      if (enhanced == null) continue;
      for (var entry in enhanced.emotions) {
        final name = entry.emotion.name;
        emotionCounts[name] = (emotionCounts[name] ?? 0) + 1;
      }
    }

    final sorted = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(5)
        .map((e) => {'emotion': e.key, 'count': e.value})
        .toList();
  }

  Map<String, dynamic> _calculateContextSummary(List<DiaryDay> weekDays) {
    double totalSleep = 0;
    int sleepCount = 0;
    double totalSleepQuality = 0;
    int sleepQualityCount = 0;
    int exerciseDays = 0;
    double totalStress = 0;
    int stressCount = 0;

    for (var day in weekDays) {
      final enhanced = day.enhancedRating;
      if (enhanced == null) continue;
      final ctx = enhanced.context;

      if (ctx.sleepHours != null) {
        totalSleep += ctx.sleepHours!;
        sleepCount++;
      }
      if (ctx.sleepQuality != null) {
        totalSleepQuality += ctx.sleepQuality!;
        sleepQualityCount++;
      }
      if (ctx.exercised == true) {
        exerciseDays++;
      }
      if (ctx.stressLevel != null) {
        totalStress += ctx.stressLevel!;
        stressCount++;
      }
    }

    return {
      'avgSleep': sleepCount > 0 ? totalSleep / sleepCount : null,
      'avgSleepQuality': sleepQualityCount > 0 ? totalSleepQuality / sleepQualityCount : null,
      'exerciseDays': exerciseDays,
      'avgStress': stressCount > 0 ? totalStress / stressCount : null,
    };
  }

  List<Map<String, dynamic>> _extractMoodTrend(List<DiaryDay> weekDays) {
    final points = <Map<String, dynamic>>[];

    for (var day in weekDays) {
      final enhanced = day.enhancedRating;
      if (enhanced == null || enhanced.quickMood == null) continue;
      points.add({
        'date': Utils.toDate(day.day),
        'valence': enhanced.quickMood!.valence,
        'arousal': enhanced.quickMood!.arousal,
      });
    }

    return points;
  }

  Map<String, dynamic> _extractHighlights(
    List<DiaryDay> weekDays,
    List<Note> weekNotes,
  ) {
    final favoriteDays = weekDays
        .where((d) => d.isFavorite)
        .map((d) => Utils.toDate(d.day))
        .toList();

    final favoriteNotes = weekNotes
        .where((n) => n.isFavorite)
        .map((n) => {
              'title': n.title,
              'category': n.noteCategory.title,
            })
        .toList();

    return {
      'favoriteDays': favoriteDays,
      'favoriteNotes': favoriteNotes,
    };
  }
}
