/// Streak data model for tracking consecutive days
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastEntryDate;
  final List<DateTime> streakDates;
  final bool isActive;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryDate,
    required this.streakDates,
    required this.isActive,
  });

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastEntryDate,
    List<DateTime>? streakDates,
    bool? isActive,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      streakDates: streakDates ?? this.streakDates,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isMilestone {
    return currentStreak == 7 ||
        currentStreak == 30 ||
        currentStreak == 100 ||
        currentStreak == 365;
  }

  /// Returns milestone value for display (use localization in UI layer)
  int get milestoneValue {
    if (currentStreak >= 365) return 365;
    if (currentStreak >= 100) return 100;
    if (currentStreak >= 30) return 30;
    if (currentStreak >= 7) return 7;
    return 0;
  }

  factory StreakData.empty() {
    return StreakData(
      currentStreak: 0,
      longestStreak: 0,
      streakDates: [],
      isActive: false,
    );
  }
}
