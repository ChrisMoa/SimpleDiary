import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:uuid/uuid.dart';

/// Pre-computed weekly review containing aggregated diary data for one
/// ISO week (Monday–Sunday). Persisted so past reviews are browsable.
class WeeklyReviewData extends DbEntity {
  final String id;

  /// Monday of the reviewed week.
  final DateTime weekStart;

  /// Sunday of the reviewed week.
  final DateTime weekEnd;

  /// ISO year of the week.
  final int year;

  /// ISO week number (1–53).
  final int weekNumber;

  /// Average daily score across the week (0–20 scale).
  final double averageScore;

  /// Number of days with diary entries (0–7).
  final int completedDays;

  /// JSON-encoded list of daily score maps:
  /// `[{"date": "...", "score": 12, "noteCount": 3, "isComplete": true, "categoryScores": {...}}]`
  final String dailyScoresJson;

  /// JSON-encoded `Map<String, double>` of category (social/productivity/sport/food) averages.
  final String categoryAveragesJson;

  /// JSON-encoded `Map<String, double>` of PERMA+ dimension averages
  /// (mood, energy, connection, purpose, achievement, engagement).
  final String permaAveragesJson;

  /// JSON-encoded list of top emotions: `[{"emotion": "joy", "count": 3}, ...]`
  final String topEmotionsJson;

  /// JSON-encoded context summary:
  /// `{"avgSleep": 7.2, "avgSleepQuality": 3.5, "exerciseDays": 4, "avgStress": 2.1}`
  final String contextSummaryJson;

  /// JSON-encoded list of mood positions:
  /// `[{"date": "...", "valence": 0.5, "arousal": 0.3}, ...]`
  final String moodTrendJson;

  /// JSON-encoded highlights:
  /// `{"favoriteDays": ["2026-03-01"], "favoriteNotes": [{"title": "...", "category": "..."}]}`
  final String highlightsJson;

  /// Current streak at the time the review was generated.
  final int currentStreak;

  /// When this review was generated.
  final DateTime createdAt;

  WeeklyReviewData({
    String? id,
    required this.weekStart,
    required this.weekEnd,
    required this.year,
    required this.weekNumber,
    this.averageScore = 0.0,
    this.completedDays = 0,
    this.dailyScoresJson = '[]',
    this.categoryAveragesJson = '{}',
    this.permaAveragesJson = '{}',
    this.topEmotionsJson = '[]',
    this.contextSummaryJson = '{}',
    this.moodTrendJson = '[]',
    this.highlightsJson = '{}',
    this.currentStreak = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'weekly_reviews';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('id'),
    DbColumn.text('weekStart'),
    DbColumn.text('weekEnd'),
    DbColumn.integer('year'),
    DbColumn.integer('weekNumber'),
    DbColumn.real('averageScore', defaultValue: '0.0'),
    DbColumn.integer('completedDays', defaultValue: '0'),
    DbColumn.text('dailyScoresJson', defaultValue: "'[]'"),
    DbColumn.text('categoryAveragesJson', defaultValue: "'{}'"),
    DbColumn.text('permaAveragesJson', defaultValue: "'{}'"),
    DbColumn.text('topEmotionsJson', defaultValue: "'[]'"),
    DbColumn.text('contextSummaryJson', defaultValue: "'{}'"),
    DbColumn.text('moodTrendJson', defaultValue: "'[]'"),
    DbColumn.text('highlightsJson', defaultValue: "'{}'"),
    DbColumn.integer('currentStreak', defaultValue: '0'),
    DbColumn.text('createdAt'),
  ];

  static const List<DbMigration> migrations = [];

  // ── Serialization (single source of truth) ─────────────────────

  @override
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
        'year': year,
        'weekNumber': weekNumber,
        'averageScore': averageScore,
        'completedDays': completedDays,
        'dailyScoresJson': dailyScoresJson,
        'categoryAveragesJson': categoryAveragesJson,
        'permaAveragesJson': permaAveragesJson,
        'topEmotionsJson': topEmotionsJson,
        'contextSummaryJson': contextSummaryJson,
        'moodTrendJson': moodTrendJson,
        'highlightsJson': highlightsJson,
        'currentStreak': currentStreak,
        'createdAt': createdAt.toIso8601String(),
      };

  static WeeklyReviewData fromDbMap(Map<String, dynamic> map) =>
      WeeklyReviewData(
        id: map['id'] as String,
        weekStart: DateTime.parse(map['weekStart'] as String),
        weekEnd: DateTime.parse(map['weekEnd'] as String),
        year: map['year'] as int,
        weekNumber: map['weekNumber'] as int,
        averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
        completedDays: map['completedDays'] as int? ?? 0,
        dailyScoresJson: map['dailyScoresJson'] as String? ?? '[]',
        categoryAveragesJson: map['categoryAveragesJson'] as String? ?? '{}',
        permaAveragesJson: map['permaAveragesJson'] as String? ?? '{}',
        topEmotionsJson: map['topEmotionsJson'] as String? ?? '[]',
        contextSummaryJson: map['contextSummaryJson'] as String? ?? '{}',
        moodTrendJson: map['moodTrendJson'] as String? ?? '[]',
        highlightsJson: map['highlightsJson'] as String? ?? '{}',
        currentStreak: map['currentStreak'] as int? ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  @override
  String get primaryKeyValue => id;

  // ── Typed accessors for JSON fields ────────────────────────────

  /// Daily scores as typed list of maps.
  List<Map<String, dynamic>> get dailyScores =>
      List<Map<String, dynamic>>.from(jsonDecode(dailyScoresJson) as List);

  /// Category averages as typed map.
  Map<String, double> get categoryAverages =>
      Map<String, double>.from(
        (jsonDecode(categoryAveragesJson) as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      );

  /// PERMA+ dimension averages as typed map.
  Map<String, double> get permaAverages =>
      Map<String, double>.from(
        (jsonDecode(permaAveragesJson) as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      );

  /// Top emotions as list of {emotion, count} maps.
  List<Map<String, dynamic>> get topEmotions =>
      List<Map<String, dynamic>>.from(jsonDecode(topEmotionsJson) as List);

  /// Context summary as typed map.
  Map<String, dynamic> get contextSummary =>
      Map<String, dynamic>.from(jsonDecode(contextSummaryJson) as Map);

  /// Mood trend data points as list of {date, valence, arousal} maps.
  List<Map<String, dynamic>> get moodTrend =>
      List<Map<String, dynamic>>.from(jsonDecode(moodTrendJson) as List);

  /// Highlights (favorite days and notes).
  Map<String, dynamic> get highlights =>
      Map<String, dynamic>.from(jsonDecode(highlightsJson) as Map);

  // ── Domain helpers ─────────────────────────────────────────────

  /// Week label, e.g. "Week 10, 2026".
  String get weekLabel => 'Week $weekNumber, $year';

  WeeklyReviewData copyWith({
    DateTime? weekStart,
    DateTime? weekEnd,
    int? year,
    int? weekNumber,
    double? averageScore,
    int? completedDays,
    String? dailyScoresJson,
    String? categoryAveragesJson,
    String? permaAveragesJson,
    String? topEmotionsJson,
    String? contextSummaryJson,
    String? moodTrendJson,
    String? highlightsJson,
    int? currentStreak,
    DateTime? createdAt,
  }) {
    return WeeklyReviewData(
      id: id,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      year: year ?? this.year,
      weekNumber: weekNumber ?? this.weekNumber,
      averageScore: averageScore ?? this.averageScore,
      completedDays: completedDays ?? this.completedDays,
      dailyScoresJson: dailyScoresJson ?? this.dailyScoresJson,
      categoryAveragesJson: categoryAveragesJson ?? this.categoryAveragesJson,
      permaAveragesJson: permaAveragesJson ?? this.permaAveragesJson,
      topEmotionsJson: topEmotionsJson ?? this.topEmotionsJson,
      contextSummaryJson: contextSummaryJson ?? this.contextSummaryJson,
      moodTrendJson: moodTrendJson ?? this.moodTrendJson,
      highlightsJson: highlightsJson ?? this.highlightsJson,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate the ISO week number for a given date.
  static int isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekday = date.weekday;
    final woy = ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) return isoWeekNumber(DateTime(date.year - 1, 12, 31));
    if (woy > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < 4) return 1;
    }
    return woy;
  }

  /// Get the Monday of a given ISO week.
  static DateTime mondayOfWeek(int year, int weekNumber) {
    final jan4 = DateTime(year, 1, 4);
    final daysFromMonday = jan4.weekday - 1;
    final firstMonday = jan4.subtract(Duration(days: daysFromMonday));
    return firstMonday.add(Duration(days: (weekNumber - 1) * 7));
  }
}
