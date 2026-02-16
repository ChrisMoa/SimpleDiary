import 'dart:math';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';

/// Service for analyzing correlations between activities and mood ratings
class MoodCorrelationService {
  /// Calculate Pearson correlation coefficient between two series
  double calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) return 0.0;

    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY =
        List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);

    final numerator = (n * sumXY) - (sumX * sumY);
    final denominator =
        sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

    if (denominator == 0) return 0.0;
    return (numerator / denominator).clamp(-1.0, 1.0);
  }

  /// Get correlation between a note category and a rating category
  /// Returns value between -1.0 (negative correlation) and 1.0 (positive correlation)
  CorrelationResult getActivityRatingCorrelation({
    required List<DiaryDay> diaryDays,
    required String noteCategory,
    required DayRatings ratingCategory,
    int minimumDays = 7,
  }) {
    // Filter days with both rating data
    final validDays = diaryDays.where((day) {
      final hasRating = day.ratings.any((r) => r.dayRating == ratingCategory);
      return hasRating;
    }).toList();

    if (validDays.length < minimumDays) {
      return CorrelationResult.insufficient();
    }

    // Build paired data series
    final activityScores = <double>[];
    final ratingScores = <double>[];

    for (final day in validDays) {
      // Activity score: count of notes in category
      final activityCount = day
          .notes
          .where((n) =>
              n.noteCategory.title.toLowerCase() == noteCategory.toLowerCase())
          .length
          .toDouble();

      // Rating score for this category
      final rating = day.ratings
          .firstWhere((r) => r.dayRating == ratingCategory)
          .score
          .toDouble();

      activityScores.add(activityCount);
      ratingScores.add(rating);
    }

    final correlation = calculateCorrelation(activityScores, ratingScores);

    // Calculate averages for context
    final avgWithActivity =
        _averageRatingWithActivity(validDays, noteCategory, ratingCategory);
    final avgWithoutActivity = _averageRatingWithoutActivity(
        validDays, noteCategory, ratingCategory);

    LogWrapper.logger.d(
        'Correlation: $noteCategory vs ${ratingCategory.name} = $correlation (n=${validDays.length})');

    return CorrelationResult(
      correlation: correlation,
      sampleSize: validDays.length,
      noteCategory: noteCategory,
      ratingCategory: ratingCategory,
      averageWithActivity: avgWithActivity,
      averageWithoutActivity: avgWithoutActivity,
    );
  }

  double _averageRatingWithActivity(
    List<DiaryDay> days,
    String noteCategory,
    DayRatings ratingCategory,
  ) {
    final daysWithActivity = days.where((day) => day.notes.any(
        (n) => n.noteCategory.title.toLowerCase() == noteCategory.toLowerCase()));

    if (daysWithActivity.isEmpty) return 0.0;

    final scores = daysWithActivity
        .map((day) =>
            day.ratings.firstWhere((r) => r.dayRating == ratingCategory).score)
        .toList();

    return scores.reduce((a, b) => a + b) / scores.length;
  }

  double _averageRatingWithoutActivity(
    List<DiaryDay> days,
    String noteCategory,
    DayRatings ratingCategory,
  ) {
    final daysWithoutActivity = days.where((day) => !day.notes.any((n) =>
        n.noteCategory.title.toLowerCase() == noteCategory.toLowerCase()));

    if (daysWithoutActivity.isEmpty) return 0.0;

    final scores = daysWithoutActivity
        .map((day) =>
            day.ratings.firstWhere((r) => r.dayRating == ratingCategory).score)
        .toList();

    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Find all strong correlations (|r| > threshold)
  List<CorrelationResult> findStrongCorrelations({
    required List<DiaryDay> diaryDays,
    required List<String> noteCategories,
    double threshold = 0.3,
  }) {
    final results = <CorrelationResult>[];

    for (final noteCategory in noteCategories) {
      for (final ratingCategory in DayRatings.values) {
        final result = getActivityRatingCorrelation(
          diaryDays: diaryDays,
          noteCategory: noteCategory,
          ratingCategory: ratingCategory,
        );

        if (result.isSignificant && result.correlation.abs() >= threshold) {
          results.add(result);
        }
      }
    }

    // Sort by absolute correlation strength
    results.sort((a, b) => b.correlation.abs().compareTo(a.correlation.abs()));
    LogWrapper.logger.i(
        'Found ${results.length} strong correlations (threshold=$threshold)');
    return results;
  }

  /// Analyze performance by day of week
  DayOfWeekAnalysis analyzeDayOfWeek(List<DiaryDay> diaryDays) {
    final dayScores = <int, List<int>>{};

    for (int i = 1; i <= 7; i++) {
      dayScores[i] = [];
    }

    for (final day in diaryDays) {
      final weekday = day.day.weekday;
      dayScores[weekday]!.add(day.overallScore);
    }

    final averages = <int, double>{};
    int? bestDay;
    int? worstDay;
    double bestAvg = 0;
    double worstAvg = double.infinity;

    for (final entry in dayScores.entries) {
      if (entry.value.isEmpty) continue;

      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      averages[entry.key] = avg;

      if (avg > bestAvg) {
        bestAvg = avg;
        bestDay = entry.key;
      }
      if (avg < worstAvg) {
        worstAvg = avg;
        worstDay = entry.key;
      }
    }

    LogWrapper.logger.d('Day of week analysis: best=$bestDay, worst=$worstDay');

    return DayOfWeekAnalysis(
      averagesByDay: averages,
      bestDay: bestDay,
      worstDay: worstDay,
      bestDayAverage: bestAvg,
      worstDayAverage: worstAvg == double.infinity ? 0 : worstAvg,
    );
  }

  /// Detect trends in a rating category over time
  TrendAnalysis detectTrend({
    required List<DiaryDay> diaryDays,
    required DayRatings ratingCategory,
    int windowDays = 14,
  }) {
    if (diaryDays.length < windowDays) {
      return TrendAnalysis.insufficient();
    }

    // Sort by date
    final sorted = List<DiaryDay>.from(diaryDays)
      ..sort((a, b) => a.day.compareTo(b.day));

    // Split into two halves
    final midpoint = sorted.length ~/ 2;
    final firstHalf = sorted.sublist(0, midpoint);
    final secondHalf = sorted.sublist(midpoint);

    double avgForPeriod(List<DiaryDay> days) {
      final scores = days
          .where((d) => d.ratings.any((r) => r.dayRating == ratingCategory))
          .map((d) =>
              d.ratings.firstWhere((r) => r.dayRating == ratingCategory).score)
          .toList();

      if (scores.isEmpty) return 0.0;
      return scores.reduce((a, b) => a + b) / scores.length.toDouble();
    }

    final firstAvg = avgForPeriod(firstHalf);
    final secondAvg = avgForPeriod(secondHalf);
    final change = secondAvg - firstAvg;
    final percentChange = firstAvg > 0 ? (change / firstAvg) * 100 : 0.0;

    TrendDirection direction;
    if (change > 0.3) {
      direction = TrendDirection.improving;
    } else if (change < -0.3) {
      direction = TrendDirection.declining;
    } else {
      direction = TrendDirection.stable;
    }

    LogWrapper.logger.d(
        'Trend: ${ratingCategory.name} = $direction (change=$change)');

    return TrendAnalysis(
      ratingCategory: ratingCategory,
      direction: direction,
      firstPeriodAverage: firstAvg,
      secondPeriodAverage: secondAvg,
      absoluteChange: change,
      percentChange: percentChange,
      sampleSize: sorted.length,
    );
  }

  /// Get all trends for all rating categories
  List<TrendAnalysis> detectAllTrends(List<DiaryDay> diaryDays) {
    return DayRatings.values
        .map((category) =>
            detectTrend(diaryDays: diaryDays, ratingCategory: category))
        .where((t) => t.isSignificant)
        .toList();
  }
}

/// Result of correlation analysis
class CorrelationResult {
  final double correlation;
  final int sampleSize;
  final String noteCategory;
  final DayRatings ratingCategory;
  final double averageWithActivity;
  final double averageWithoutActivity;
  final bool isSignificant;

  CorrelationResult({
    required this.correlation,
    required this.sampleSize,
    required this.noteCategory,
    required this.ratingCategory,
    required this.averageWithActivity,
    required this.averageWithoutActivity,
  }) : isSignificant = sampleSize >= 7;

  CorrelationResult.insufficient()
      : correlation = 0,
        sampleSize = 0,
        noteCategory = '',
        ratingCategory = DayRatings.social,
        averageWithActivity = 0,
        averageWithoutActivity = 0,
        isSignificant = false;

  /// Difference in average rating with vs without activity
  double get impact => averageWithActivity - averageWithoutActivity;

  /// Human-readable strength
  String get strengthLabel {
    final abs = correlation.abs();
    if (abs >= 0.7) return 'strong';
    if (abs >= 0.4) return 'moderate';
    if (abs >= 0.2) return 'weak';
    return 'negligible';
  }

  bool get isPositive => correlation > 0;
}

/// Day of week analysis results
class DayOfWeekAnalysis {
  final Map<int, double> averagesByDay;
  final int? bestDay;
  final int? worstDay;
  final double bestDayAverage;
  final double worstDayAverage;

  DayOfWeekAnalysis({
    required this.averagesByDay,
    required this.bestDay,
    required this.worstDay,
    required this.bestDayAverage,
    required this.worstDayAverage,
  });

  String get bestDayName => _dayName(bestDay);
  String get worstDayName => _dayName(worstDay);

  String _dayName(int? day) {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return day != null && day >= 1 && day <= 7 ? names[day] : 'Unknown';
  }

  double get variance => bestDayAverage - worstDayAverage;
  bool get hasSignificantVariance => variance > 2.0;
}

/// Trend direction
enum TrendDirection { improving, declining, stable }

/// Trend analysis results
class TrendAnalysis {
  final DayRatings ratingCategory;
  final TrendDirection direction;
  final double firstPeriodAverage;
  final double secondPeriodAverage;
  final double absoluteChange;
  final double percentChange;
  final int sampleSize;
  final bool isSignificant;

  TrendAnalysis({
    required this.ratingCategory,
    required this.direction,
    required this.firstPeriodAverage,
    required this.secondPeriodAverage,
    required this.absoluteChange,
    required this.percentChange,
    required this.sampleSize,
  }) : isSignificant = sampleSize >= 14 && absoluteChange.abs() > 0.3;

  TrendAnalysis.insufficient()
      : ratingCategory = DayRatings.social,
        direction = TrendDirection.stable,
        firstPeriodAverage = 0,
        secondPeriodAverage = 0,
        absoluteChange = 0,
        percentChange = 0,
        sampleSize = 0,
        isSignificant = false;
}
