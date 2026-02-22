import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generates 14 days of realistic sample diary entries and notes so that
/// new users can explore the app without entering real data.
///
/// Data is inserted via the existing Riverpod providers (same path as
/// normal user edits) so that all UI views (dashboard, calendar, charts)
/// show populated, realistic content immediately.
///
/// Call [generate] after the user DB is initialised (i.e. after
/// [_onUserChanged] completes in MainPage). Call [clear] to wipe demo data
/// when the user creates a real account or explicitly opts out.
class DemoDataGenerator {
  final WidgetRef ref;

  const DemoDataGenerator(this.ref);

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> generate() async {
    final today = _dateOnly(DateTime.now());
    for (int i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      await _addDiaryDay(day);
      await _addNotesForDay(day);
    }
  }

  Future<void> clear() async {
    final today = _dateOnly(DateTime.now());
    for (int i = 0; i < 14; i++) {
      final day = today.subtract(Duration(days: i));
      final isoDate = _isoDate(day);
      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      final match = diaryDays.where((d) => d.primaryKeyValue == isoDate);
      if (match.isNotEmpty) {
        await ref
            .read(diaryDayLocalDbDataProvider.notifier)
            .deleteElement(match.first);
      }
    }
    // Notes are tied to dates; the note list update clears the calendar view.
    final notes = ref.read(notesLocalDataProvider);
    final cutoff = today.subtract(const Duration(days: 14));
    final demoNotes = notes.where((n) => !n.from.isBefore(cutoff)).toList();
    for (final note in demoNotes) {
      await ref.read(notesLocalDataProvider.notifier).deleteElement(note);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<void> _addDiaryDay(DateTime day) async {
    final diaryDay = DiaryDay(
      day: day,
      ratings: _ratingsForDay(day),
    );
    await ref
        .read(diaryDayLocalDbDataProvider.notifier)
        .addOrUpdateElement(diaryDay);
  }

  /// Returns the 4 DayRating values for [day] following a realistic pattern:
  /// - Gym days (Mon/Wed/Fri): high sport, good productivity
  /// - Work days (Tue/Thu):    high productivity, low sport
  /// - Weekends (Sat/Sun):     high social & food, lower productivity
  List<DayRating> _ratingsForDay(DateTime day) {
    final wd = day.weekday; // 1=Mon…7=Sun
    final isGym = wd == 1 || wd == 3 || wd == 5;
    final isWeekend = wd == 6 || wd == 7;

    int social, productivity, sport, food;

    if (isGym) {
      social = 3;
      productivity = 4;
      sport = 5;
      food = 3;
    } else if (isWeekend) {
      social = 5;
      productivity = 2;
      sport = 3;
      food = 4;
    } else {
      // Tue / Thu: regular work day
      social = 3;
      productivity = 4;
      sport = 2;
      food = 3;
    }

    return [
      DayRating(dayRating: DayRatings.social, score: social),
      DayRating(dayRating: DayRatings.productivity, score: productivity),
      DayRating(dayRating: DayRatings.sport, score: sport),
      DayRating(dayRating: DayRatings.food, score: food),
    ];
  }

  Future<void> _addNotesForDay(DateTime day) async {
    final wd = day.weekday;
    final isGym = wd == 1 || wd == 3 || wd == 5;
    final isWeekend = wd == 6 || wd == 7;
    final isWorkDay = !isWeekend;

    // Sleep note — every day (previous night → morning)
    await _addNote(
      title: 'Sleep',
      description: 'Good night\'s rest',
      from: day.copyWith(hour: 22, minute: 30),
      to: day.copyWith(hour: 22, minute: 30).add(const Duration(hours: 8)),
      category: _cat('Sleep'),
      isAllDay: false,
    );

    if (isWorkDay) {
      // Morning stand-up
      await _addNote(
        title: 'Daily Stand-up',
        description: 'Quick team sync on tasks and blockers',
        from: day.copyWith(hour: 9, minute: 0),
        to: day.copyWith(hour: 9, minute: 30),
        category: _cat('Work'),
      );

      // Deep work block
      await _addNote(
        title: 'Deep Work',
        description: 'Focused coding / planning session',
        from: day.copyWith(hour: 10, minute: 0),
        to: day.copyWith(hour: 12, minute: 0),
        category: _cat('Work'),
      );

      // Lunch
      await _addNote(
        title: 'Lunch',
        description: 'Healthy meal with colleagues',
        from: day.copyWith(hour: 12, minute: 30),
        to: day.copyWith(hour: 13, minute: 15),
        category: _cat('Food'),
      );

      // Afternoon work block
      await _addNote(
        title: 'Afternoon Tasks',
        description: 'Emails, reviews and wrap-up',
        from: day.copyWith(hour: 14, minute: 0),
        to: day.copyWith(hour: 17, minute: 0),
        category: _cat('Work'),
      );
    }

    if (isGym) {
      await _addNote(
        title: 'Gym Session',
        description:
            isGym && day.weekday == 1 ? 'Chest & triceps' : 'Back & biceps',
        from: day.copyWith(hour: 17, minute: 30),
        to: day.copyWith(hour: 19, minute: 0),
        category: _cat('Gym'),
      );
    }

    if (isWeekend) {
      await _addNote(
        title: 'Weekend Leisure',
        description: wd == 6 ? 'Bike ride in the park' : 'Movie night at home',
        from: day.copyWith(hour: 14, minute: 0),
        to: day.copyWith(hour: 16, minute: 30),
        category: _cat('Leisure'),
      );

      await _addNote(
        title: 'Weekend Dinner',
        description: 'Cooking a nice meal',
        from: day.copyWith(hour: 19, minute: 0),
        to: day.copyWith(hour: 20, minute: 0),
        category: _cat('Food'),
      );
    }
  }

  Future<void> _addNote({
    required String title,
    required String description,
    required DateTime from,
    required DateTime to,
    required NoteCategory category,
    bool isAllDay = false,
  }) async {
    final note = Note(
      title: title,
      description: description,
      from: from,
      to: to,
      noteCategory: category,
      isAllDay: isAllDay,
    );
    await ref.read(notesLocalDataProvider.notifier).addOrUpdateElement(note);
  }

  NoteCategory _cat(String title) => NoteCategory.fromString(title);

  DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  String _isoDate(DateTime dt) =>
      dt.toIso8601String().split('T')[0];
}
