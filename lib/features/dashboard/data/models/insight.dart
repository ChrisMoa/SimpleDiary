/// Insight types for categorizing different insights
enum InsightType {
  achievement,
  improvement,
  warning,
  suggestion,
  milestone,
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

  Insight({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    DateTime? createdAt,
    this.metadata,
    this.dynamicData,
  }) : createdAt = createdAt ?? DateTime.now();

  Insight copyWith({
    String? title,
    String? description,
    InsightType? type,
    String? icon,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? dynamicData,
  }) {
    return Insight(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      dynamicData: dynamicData ?? this.dynamicData,
    );
  }
}
