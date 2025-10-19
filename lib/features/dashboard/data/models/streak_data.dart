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

  String get milestoneText {
    if (currentStreak >= 365) return '🎉 1 Jahr Streak!';
    if (currentStreak >= 100) return '💯 100 Tage Streak!';
    if (currentStreak >= 30) return '🌟 30 Tage Streak!';
    if (currentStreak >= 7) return '🔥 1 Woche Streak!';
    return '';
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
