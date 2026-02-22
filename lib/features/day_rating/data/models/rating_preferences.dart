import 'dart:convert';

/// User preferences controlling which rating tiers are shown.
enum RatingMode {
  /// Tier 1 only – just the mood map (~10 seconds).
  quick,

  /// Tier 1 + Tier 2 – mood map and core PERMA+ dimensions (~30 seconds).
  balanced,

  /// All four tiers including emotion wheel and context factors (~60+ seconds).
  detailed,

  /// User-selected combination of tiers.
  custom,
}

/// Persisted preferences for the enhanced rating system.
class RatingPreferences {
  /// Global rating mode selection.
  final RatingMode mode;

  /// Which PERMA+ dimensions to show in balanced/custom modes.
  /// Dimension keys: 'mood', 'energy', 'connection', 'purpose', 'achievement', 'engagement'
  final List<String> enabledDimensions;

  /// Show the quick circumplex mood map (Tier 1).
  final bool showQuickMood;

  /// Show the emotion wheel (Tier 3).
  final bool showEmotionWheel;

  /// Show contextual factors (Tier 4).
  final bool showContextFactors;

  /// Fall back to the legacy 4-category system instead of the enhanced one.
  final bool useLegacyMode;

  const RatingPreferences({
    this.mode = RatingMode.balanced,
    this.enabledDimensions = const [
      'mood',
      'energy',
      'connection',
      'purpose',
      'achievement',
      'engagement',
    ],
    this.showQuickMood = true,
    this.showEmotionWheel = false,
    this.showContextFactors = false,
    this.useLegacyMode = false,
  });

  RatingPreferences copyWith({
    RatingMode? mode,
    List<String>? enabledDimensions,
    bool? showQuickMood,
    bool? showEmotionWheel,
    bool? showContextFactors,
    bool? useLegacyMode,
  }) =>
      RatingPreferences(
        mode: mode ?? this.mode,
        enabledDimensions: enabledDimensions ?? this.enabledDimensions,
        showQuickMood: showQuickMood ?? this.showQuickMood,
        showEmotionWheel: showEmotionWheel ?? this.showEmotionWheel,
        showContextFactors: showContextFactors ?? this.showContextFactors,
        useLegacyMode: useLegacyMode ?? this.useLegacyMode,
      );

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        'enabledDimensions': enabledDimensions,
        'showQuickMood': showQuickMood,
        'showEmotionWheel': showEmotionWheel,
        'showContextFactors': showContextFactors,
        'useLegacyMode': useLegacyMode,
      };

  factory RatingPreferences.fromMap(Map<String, dynamic> map) =>
      RatingPreferences(
        mode: RatingMode.values.firstWhere(
          (m) => m.name == map['mode'],
          orElse: () => RatingMode.balanced,
        ),
        enabledDimensions:
            List<String>.from(map['enabledDimensions'] as List? ?? []),
        showQuickMood: map['showQuickMood'] as bool? ?? true,
        showEmotionWheel: map['showEmotionWheel'] as bool? ?? false,
        showContextFactors: map['showContextFactors'] as bool? ?? false,
        useLegacyMode: map['useLegacyMode'] as bool? ?? false,
      );

  String toJson() => jsonEncode(toMap());

  factory RatingPreferences.fromJson(String json) =>
      RatingPreferences.fromMap(jsonDecode(json) as Map<String, dynamic>);
}
