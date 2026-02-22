import 'dart:convert';

/// Circumplex position for quick mood entry (Russell, 1980).
///
/// Maps to a 2D space:
/// - [valence]: -1.0 (negative/unpleasant) to +1.0 (positive/pleasant)
/// - [arousal]: -1.0 (low energy/calm) to +1.0 (high energy/activated)
class MoodPosition {
  final double valence;
  final double arousal;
  final DateTime timestamp;

  const MoodPosition({
    required this.valence,
    required this.arousal,
    required this.timestamp,
  });

  /// The mood quadrant derived from valence and arousal.
  MoodQuadrant get quadrant {
    if (valence >= 0 && arousal >= 0) return MoodQuadrant.highEnergyPositive;
    if (valence >= 0 && arousal < 0) return MoodQuadrant.lowEnergyPositive;
    if (valence < 0 && arousal >= 0) return MoodQuadrant.highEnergyNegative;
    return MoodQuadrant.lowEnergyNegative;
  }

  /// Human-readable label for the approximate mood state.
  String get label {
    if (arousal > 0.5 && valence > 0.5) return 'Excited';
    if (arousal > 0.5 && valence < -0.5) return 'Anxious';
    if (arousal < -0.5 && valence > 0.5) return 'Calm';
    if (arousal < -0.5 && valence < -0.5) return 'Sad';
    if (valence > 0.3) return 'Pleasant';
    if (valence < -0.3) return 'Unpleasant';
    return 'Neutral';
  }

  MoodPosition copyWith({double? valence, double? arousal, DateTime? timestamp}) =>
      MoodPosition(
        valence: valence ?? this.valence,
        arousal: arousal ?? this.arousal,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'valence': valence,
        'arousal': arousal,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MoodPosition.fromMap(Map<String, dynamic> map) => MoodPosition(
        valence: (map['valence'] as num?)?.toDouble() ?? 0.0,
        arousal: (map['arousal'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

/// Four quadrants of the circumplex model.
enum MoodQuadrant {
  /// High arousal + positive valence (Excited, Enthusiastic, Alert)
  highEnergyPositive,

  /// Low arousal + positive valence (Calm, Relaxed, Content)
  lowEnergyPositive,

  /// High arousal + negative valence (Anxious, Stressed, Angry)
  highEnergyNegative,

  /// Low arousal + negative valence (Sad, Depressed, Bored)
  lowEnergyNegative,
}

/// PERMA+ based wellbeing dimensions (Seligman, 2011).
///
/// Each field is on a 1–5 scale; 0 means "not rated yet".
class WellbeingRating {
  /// P – Positive Emotion: Overall emotional state today.
  final int mood;

  /// V – Vitality: Physical energy and alertness.
  final int energy;

  /// R – Relationships: Quality of social connections.
  final int connection;

  /// M – Meaning: Sense of purpose and direction.
  final int purpose;

  /// A – Accomplishment: Progress on goals and tasks.
  final int achievement;

  /// E – Engagement: Flow states, being absorbed in activities.
  final int engagement;

  const WellbeingRating({
    this.mood = 0,
    this.energy = 0,
    this.connection = 0,
    this.purpose = 0,
    this.achievement = 0,
    this.engagement = 0,
  });

  /// Sum of all rated dimensions (max 30).
  int get totalScore =>
      mood + energy + connection + purpose + achievement + engagement;

  /// Average of only the rated (>0) dimensions; 0.0 if nothing rated.
  double get averageScore {
    final rated = [mood, energy, connection, purpose, achievement, engagement]
        .where((s) => s > 0)
        .toList();
    if (rated.isEmpty) return 0.0;
    return rated.reduce((a, b) => a + b) / rated.length;
  }

  /// Returns true when at least the two core dimensions are rated.
  bool get isComplete => mood > 0 && energy > 0;

  WellbeingRating copyWith({
    int? mood,
    int? energy,
    int? connection,
    int? purpose,
    int? achievement,
    int? engagement,
  }) =>
      WellbeingRating(
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
        connection: connection ?? this.connection,
        purpose: purpose ?? this.purpose,
        achievement: achievement ?? this.achievement,
        engagement: engagement ?? this.engagement,
      );

  Map<String, dynamic> toMap() => {
        'mood': mood,
        'energy': energy,
        'connection': connection,
        'purpose': purpose,
        'achievement': achievement,
        'engagement': engagement,
      };

  factory WellbeingRating.fromMap(Map<String, dynamic> map) => WellbeingRating(
        mood: (map['mood'] as num?)?.toInt() ?? 0,
        energy: (map['energy'] as num?)?.toInt() ?? 0,
        connection: (map['connection'] as num?)?.toInt() ?? 0,
        purpose: (map['purpose'] as num?)?.toInt() ?? 0,
        achievement: (map['achievement'] as num?)?.toInt() ?? 0,
        engagement: (map['engagement'] as num?)?.toInt() ?? 0,
      );

  factory WellbeingRating.empty() => const WellbeingRating();
}

/// A specific emotion with an intensity level (emotional granularity).
class EmotionEntry {
  final EmotionType emotion;

  /// Intensity: 1 = mild, 2 = moderate, 3 = strong.
  final int intensity;

  const EmotionEntry({
    required this.emotion,
    required this.intensity,
  });

  EmotionEntry copyWith({EmotionType? emotion, int? intensity}) =>
      EmotionEntry(
        emotion: emotion ?? this.emotion,
        intensity: intensity ?? this.intensity,
      );

  Map<String, dynamic> toMap() => {
        'emotion': emotion.name,
        'intensity': intensity,
      };

  factory EmotionEntry.fromMap(Map<String, dynamic> map) => EmotionEntry(
        emotion: EmotionType.values.firstWhere(
          (e) => e.name == map['emotion'],
          orElse: () => EmotionType.neutral,
        ),
        intensity: (map['intensity'] as num?)?.toInt() ?? 1,
      );
}

/// Emotion types covering the primary dimensions of the emotion wheel.
enum EmotionType {
  // Positive
  joy,
  gratitude,
  serenity,
  interest,
  hope,
  pride,
  amusement,
  inspiration,
  awe,
  love,
  // Negative
  sadness,
  anger,
  fear,
  disgust,
  shame,
  guilt,
  frustration,
  loneliness,
  anxiety,
  // Neutral / mixed
  neutral,
  surprised,
}

/// Contextual factors that may influence mood.
class ContextualFactors {
  final double? sleepHours;

  /// 1–5 scale; null = not entered.
  final int? sleepQuality;
  final bool? exercised;

  /// 1–5 scale; null = not entered.
  final int? stressLevel;

  /// User-defined tags (e.g. "travel", "sick", "date night").
  final List<String> tags;

  const ContextualFactors({
    this.sleepHours,
    this.sleepQuality,
    this.exercised,
    this.stressLevel,
    this.tags = const [],
  });

  ContextualFactors copyWith({
    double? sleepHours,
    int? sleepQuality,
    bool? exercised,
    int? stressLevel,
    List<String>? tags,
  }) =>
      ContextualFactors(
        sleepHours: sleepHours ?? this.sleepHours,
        sleepQuality: sleepQuality ?? this.sleepQuality,
        exercised: exercised ?? this.exercised,
        stressLevel: stressLevel ?? this.stressLevel,
        tags: tags ?? this.tags,
      );

  Map<String, dynamic> toMap() => {
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'exercised': exercised,
        'stressLevel': stressLevel,
        'tags': tags,
      };

  factory ContextualFactors.fromMap(Map<String, dynamic> map) =>
      ContextualFactors(
        sleepHours: (map['sleepHours'] as num?)?.toDouble(),
        sleepQuality: (map['sleepQuality'] as num?)?.toInt(),
        exercised: map['exercised'] as bool?,
        stressLevel: (map['stressLevel'] as num?)?.toInt(),
        tags: List<String>.from(map['tags'] as List? ?? []),
      );

  factory ContextualFactors.empty() => const ContextualFactors();
}

/// Complete enhanced day rating combining all four tiers.
///
/// Tier 1: [quickMood] – Circumplex-based 2D mood position (~10 s)
/// Tier 2: [wellbeing] – PERMA+ dimension sliders (~30 s)
/// Tier 3: [emotions] – Specific emotion wheel selection (~60 s)
/// Tier 4: [context] – Sleep, exercise, stress, tags
class EnhancedDayRating {
  final DateTime date;

  /// Tier 1: Quick circumplex mood position (optional).
  final MoodPosition? quickMood;

  /// Tier 2: PERMA+ wellbeing dimensions.
  final WellbeingRating wellbeing;

  /// Tier 3: Selected specific emotions with intensity.
  final List<EmotionEntry> emotions;

  /// Tier 4: Contextual factors.
  final ContextualFactors context;

  const EnhancedDayRating({
    required this.date,
    this.quickMood,
    this.wellbeing = const WellbeingRating(),
    this.emotions = const [],
    this.context = const ContextualFactors(),
  });

  factory EnhancedDayRating.empty(DateTime date) => EnhancedDayRating(date: date);

  /// Overall score scaled to 0–20 for backward compatibility with dashboard.
  ///
  /// Uses wellbeing total (0–30) scaled to 0–20.
  /// Falls back to 0 if nothing is rated.
  int get overallScore {
    if (wellbeing.totalScore > 0) {
      return ((wellbeing.totalScore / 30.0) * 20).round();
    }
    return 0;
  }

  EnhancedDayRating copyWith({
    DateTime? date,
    MoodPosition? quickMood,
    WellbeingRating? wellbeing,
    List<EmotionEntry>? emotions,
    ContextualFactors? context,
  }) =>
      EnhancedDayRating(
        date: date ?? this.date,
        quickMood: quickMood ?? this.quickMood,
        wellbeing: wellbeing ?? this.wellbeing,
        emotions: emotions ?? this.emotions,
        context: context ?? this.context,
      );

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'quickMood': quickMood?.toMap(),
        'wellbeing': wellbeing.toMap(),
        'emotions': emotions.map((e) => e.toMap()).toList(),
        'context': context.toMap(),
      };

  factory EnhancedDayRating.fromMap(Map<String, dynamic> map) =>
      EnhancedDayRating(
        date: DateTime.parse(map['date'] as String),
        quickMood: map['quickMood'] != null
            ? MoodPosition.fromMap(map['quickMood'] as Map<String, dynamic>)
            : null,
        wellbeing: map['wellbeing'] != null
            ? WellbeingRating.fromMap(map['wellbeing'] as Map<String, dynamic>)
            : const WellbeingRating(),
        emotions: (map['emotions'] as List?)
                ?.map((e) => EmotionEntry.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        context: map['context'] != null
            ? ContextualFactors.fromMap(map['context'] as Map<String, dynamic>)
            : const ContextualFactors(),
      );

  String toJson() => jsonEncode(toMap());

  factory EnhancedDayRating.fromJson(String json) =>
      EnhancedDayRating.fromMap(jsonDecode(json) as Map<String, dynamic>);
}
