/// Insight types for categorizing different insights
enum InsightType {
  achievement,
  improvement,
  warning,
  suggestion,
  milestone,
  // NEW types for pattern analysis
  correlation, // Activity correlates with rating
  trend, // Rating trending up/down
  dayPattern, // Best/worst day of week
  recommendation, // Actionable suggestion
}

/// Insight model for displaying smart insights to the user
class Insight {
  final String title;
  final String description;
  final InsightType type;
  final String icon;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final String? dynamicData;
  final PatternData? patternData; // NEW

  Insight({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    DateTime? createdAt,
    this.metadata,
    this.dynamicData,
    this.patternData, // NEW
  }) : createdAt = createdAt ?? DateTime.now();

  Insight copyWith({
    String? title,
    String? description,
    InsightType? type,
    String? icon,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? dynamicData,
    PatternData? patternData,
  }) {
    return Insight(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      dynamicData: dynamicData ?? this.dynamicData,
      patternData: patternData ?? this.patternData,
    );
  }
}

/// Data for pattern-based insights
class PatternData {
  final String patternType; // 'correlation', 'trend', 'dayOfWeek'
  final double strength; // 0.0 - 1.0
  final String? activityCategory;
  final String? ratingCategory;
  final Map<String, dynamic>? statistics;

  PatternData({
    required this.patternType,
    required this.strength,
    this.activityCategory,
    this.ratingCategory,
    this.statistics,
  });

  /// Strength as percentage (0-100)
  int get strengthPercent => (strength.abs() * 100).round();

  /// Is this a strong pattern worth highlighting?
  bool get isStrong => strength.abs() >= 0.4;
}
