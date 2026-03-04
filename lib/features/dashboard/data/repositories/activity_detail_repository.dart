import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

/// Statistics for a single activity (note category)
class ActivityStats {
  final String activityName;
  final NoteCategory category;
  final int totalNotes;
  final int associatedDays;
  final double averageDayRating;
  final DateTime? firstOccurrence;
  final DateTime? lastOccurrence;

  const ActivityStats({
    required this.activityName,
    required this.category,
    required this.totalNotes,
    required this.associatedDays,
    required this.averageDayRating,
    this.firstOccurrence,
    this.lastOccurrence,
  });

  ActivityStats copyWith({
    String? activityName,
    NoteCategory? category,
    int? totalNotes,
    int? associatedDays,
    double? averageDayRating,
    DateTime? firstOccurrence,
    DateTime? lastOccurrence,
  }) {
    return ActivityStats(
      activityName: activityName ?? this.activityName,
      category: category ?? this.category,
      totalNotes: totalNotes ?? this.totalNotes,
      associatedDays: associatedDays ?? this.associatedDays,
      averageDayRating: averageDayRating ?? this.averageDayRating,
      firstOccurrence: firstOccurrence ?? this.firstOccurrence,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
    );
  }
}

/// Summary entry for dashboard display (category name + count)
class ActivitySummary {
  final String activityName;
  final NoteCategory category;
  final int count;

  const ActivitySummary({
    required this.activityName,
    required this.category,
    required this.count,
  });
}

/// Repository for activity detail calculations
class ActivityDetailRepository {
  /// Get statistics for a specific activity category
  ActivityStats getActivityStats({
    required String activityName,
    required List<Note> notes,
    required List<DiaryDay> diaryDays,
  }) {
    final activityNotes = getNotesByActivity(activityName, notes);
    final activityDays = getDaysByActivity(activityName, notes, diaryDays);

    double averageRating = 0;
    if (activityDays.isNotEmpty) {
      double totalScore = 0;
      int scoredDays = 0;
      for (final day in activityDays) {
        if (day.ratings.isNotEmpty) {
          totalScore += day.overallScore;
          scoredDays++;
        }
      }
      if (scoredDays > 0) {
        averageRating = totalScore / scoredDays;
      }
    }

    DateTime? firstOccurrence;
    DateTime? lastOccurrence;
    if (activityNotes.isNotEmpty) {
      final sorted = List<Note>.from(activityNotes)
        ..sort((a, b) => a.from.compareTo(b.from));
      firstOccurrence = sorted.first.from;
      lastOccurrence = sorted.last.from;
    }

    final category = activityNotes.isNotEmpty
        ? activityNotes.first.noteCategory
        : NoteCategory.fromString(activityName);

    return ActivityStats(
      activityName: activityName,
      category: category,
      totalNotes: activityNotes.length,
      associatedDays: activityDays.length,
      averageDayRating: averageRating,
      firstOccurrence: firstOccurrence,
      lastOccurrence: lastOccurrence,
    );
  }

  /// Get all notes for a specific activity category
  List<Note> getNotesByActivity(String activityName, List<Note> notes) {
    return notes
        .where((note) => note.noteCategory.title == activityName)
        .toList()
      ..sort((a, b) => b.from.compareTo(a.from));
  }

  /// Get all diary days that contain notes of a specific activity category
  List<DiaryDay> getDaysByActivity(
    String activityName,
    List<Note> notes,
    List<DiaryDay> diaryDays,
  ) {
    final activityNotes = getNotesByActivity(activityName, notes);
    final activityDates = activityNotes
        .map((note) => DateTime(note.from.year, note.from.month, note.from.day))
        .toSet();

    return diaryDays
        .where((day) => activityDates.any((date) => Utils.isSameDay(day.day, date)))
        .toList()
      ..sort((a, b) => b.day.compareTo(a.day));
  }

  /// Extract top activities with counts and category info for dashboard display
  List<ActivitySummary> extractTopActivitySummaries(
    List<Note> notes,
    List<NoteCategory> categories,
  ) {
    if (notes.isEmpty) return [];

    final Map<String, int> activityCounts = {};
    final Map<String, NoteCategory> categoryMap = {};

    for (final note in notes) {
      final name = note.noteCategory.title;
      activityCounts[name] = (activityCounts[name] ?? 0) + 1;
      categoryMap[name] = note.noteCategory;
    }

    final sorted = activityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) {
      final category = categoryMap[entry.key] ??
          NoteCategory.fromString(entry.key);
      return ActivitySummary(
        activityName: entry.key,
        category: category,
        count: entry.value,
      );
    }).toList();
  }
}
