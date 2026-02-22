import 'dart:convert';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';

class DiaryDay extends DbEntity {
  DateTime day;
  List<Note> notes = [];
  List<DayRating> ratings;
  bool isFavorite;

  /// Enhanced PERMA+-based rating (Tier 1–4). Null when the day was saved
  /// with the legacy system only.
  EnhancedDayRating? enhancedRating;

  DiaryDay({
    required this.day,
    required this.ratings,
    this.isFavorite = false,
    this.enhancedRating,
  });

  factory DiaryDay.fromEmpty() {
    return DiaryDay(day: DateTime.now(), ratings: [], isFavorite: false);
  }

  // ── Schema (single source of truth) ────────────────────────────

  static const String tableName = 'diaryDays';

  static const List<DbColumn> columns = [
    DbColumn.textPrimaryKey('day'),
    DbColumn.text('ratings'),
    DbColumn.integer('isFavorite', defaultValue: '0'),
    DbColumn.text('enhancedRating', isNotNull: false),
  ];

  static final List<DbMigration> migrations = [
    DbMigration.addColumn(
      version: 1,
      columnName: 'isFavorite',
      columnDefinition: 'INTEGER NOT NULL DEFAULT 0',
    ),
    DbMigration.addColumn(
      version: 2,
      columnName: 'enhancedRating',
      columnDefinition: 'TEXT',
    ),
  ];

  // ── SQLite serialization (single source of truth) ──────────────

  @override
  Map<String, dynamic> toDbMap() {
    List<Map<String, dynamic>> ratingsList = [];
    for (var rating in ratings) {
      ratingsList.add(rating.toMap());
    }
    return {
      'day': Utils.toDate(day),
      'ratings': jsonEncode(ratingsList),
      'isFavorite': isFavorite ? 1 : 0,
      'enhancedRating': enhancedRating?.toJson(),
    };
  }

  static DiaryDay fromDbMap(Map<String, dynamic> map) {
    List<DayRating> ratings = [];
    var ratingsList = jsonDecode(map['ratings']);
    for (var rating in ratingsList) {
      try {
        ratings.add(DayRating.fromMap(rating));
      } catch (e) {
        LogWrapper.logger.e('cannot read $rating');
      }
    }

    EnhancedDayRating? enhancedRating;
    final enhancedJson = map['enhancedRating'] as String?;
    if (enhancedJson != null && enhancedJson.isNotEmpty) {
      try {
        enhancedRating = EnhancedDayRating.fromJson(enhancedJson);
      } catch (e) {
        LogWrapper.logger.e('cannot read enhancedRating: $e');
      }
    }

    return DiaryDay(
      day: Utils.fromDate(map['day']),
      ratings: ratings,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      enhancedRating: enhancedRating,
    );
  }

  @override
  String get primaryKeyValue => day.toIso8601String().split('T')[0];

  // ── JSON export/import serialization (different format) ────────

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> ratingsList = [];
    for (var rating in ratings) {
      ratingsList.add(rating.toMap());
    }
    List<Map<String, dynamic>> notesList = [];
    for (var note in notes) {
      notesList.add(note.toMap());
    }

    return {
      'day': Utils.toDate(day),
      'ratings': ratingsList,
      'notes': notesList,
      'isFavorite': isFavorite,
      'enhancedRating': enhancedRating?.toMap(),
    };
  }

  factory DiaryDay.fromMap(Map<String, dynamic> map) {
    List<DayRating> ratings = [];
    for (Map<String, dynamic> rating in map['ratings']) {
      ratings.add(DayRating.fromMap(rating));
    }
    List<Note> noteList = [];
    for (Map<String, dynamic> notes in map['notes']) {
      noteList.add(Note.fromMap(notes));
    }

    EnhancedDayRating? enhancedRating;
    if (map['enhancedRating'] != null) {
      try {
        enhancedRating = EnhancedDayRating.fromMap(
          map['enhancedRating'] as Map<String, dynamic>,
        );
      } catch (e) {
        LogWrapper.logger.e('cannot read enhancedRating from export: $e');
      }
    }

    var diaryDay = DiaryDay(
      day: Utils.fromDate(map['day']),
      ratings: ratings,
      isFavorite: map['isFavorite'] ?? false,
      enhancedRating: enhancedRating,
    );
    diaryDay.notes = noteList;
    return diaryDay;
  }

  // ── Domain helpers ─────────────────────────────────────────────

  int get overallScore {
    int overallScore = 0;
    for (var value in ratings) {
      overallScore += value.score;
    }
    return overallScore;
  }
}
