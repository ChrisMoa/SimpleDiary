/// Weekly statistics model
class WeekStats {
  final double averageScore;
  final int completedDays;
  final Map<String, double> categoryAverages;
  final List<DayScore> dailyScores;

  WeekStats({
    required this.averageScore,
    required this.completedDays,
    required this.categoryAverages,
    required this.dailyScores,
  });

  WeekStats copyWith({
    double? averageScore,
    int? completedDays,
    Map<String, double>? categoryAverages,
    List<DayScore>? dailyScores,
  }) {
    return WeekStats(
      averageScore: averageScore ?? this.averageScore,
      completedDays: completedDays ?? this.completedDays,
      categoryAverages: categoryAverages ?? this.categoryAverages,
      dailyScores: dailyScores ?? this.dailyScores,
    );
  }
}

/// Individual day score for the week overview
class DayScore {
  final DateTime date;
  final int totalScore;
  final Map<String, int> categoryScores;
  final int noteCount;
  final bool isComplete;

  DayScore({
    required this.date,
    required this.totalScore,
    required this.categoryScores,
    required this.noteCount,
    required this.isComplete,
  });

  DayScore copyWith({
    DateTime? date,
    int? totalScore,
    Map<String, int>? categoryScores,
    int? noteCount,
    bool? isComplete,
  }) {
    return DayScore(
      date: date ?? this.date,
      totalScore: totalScore ?? this.totalScore,
      categoryScores: categoryScores ?? this.categoryScores,
      noteCount: noteCount ?? this.noteCount,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
