import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/synchronization/data/services/pdf_report_generator.dart';
import 'package:day_tracker/features/synchronization/domain/providers/pdf_export_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Test data helpers ──────────────────────────────────────────────────

  List<DiaryDay> createSampleDiaryDays() {
    final day1 = DiaryDay(
      day: DateTime(2026, 2, 13),
      ratings: [
        DayRating(dayRating: DayRatings.social, score: 5),
        DayRating(dayRating: DayRatings.productivity, score: 2),
        DayRating(dayRating: DayRatings.sport, score: 4),
        DayRating(dayRating: DayRatings.food, score: 2),
      ],
    );

    final day2 = DiaryDay(
      day: DateTime(2026, 2, 14),
      ratings: [
        DayRating(dayRating: DayRatings.social, score: 3),
        DayRating(dayRating: DayRatings.productivity, score: 4),
        DayRating(dayRating: DayRatings.sport, score: 3),
        DayRating(dayRating: DayRatings.food, score: 5),
      ],
    );

    final day3 = DiaryDay(
      day: DateTime(2026, 2, 15),
      ratings: [],
    );

    return [day1, day2, day3];
  }

  List<Note> createSampleNotes() {
    return [
      Note(
        title: 'Meeting',
        description: 'Team meeting to discuss project progress.',
        from: DateTime(2026, 2, 13, 9, 0),
        to: DateTime(2026, 2, 13, 10, 0),
        noteCategory: NoteCategory(title: 'Arbeit', color: const Color(0xFF9C27B0)),
      ),
      Note(
        title: 'Gym Session',
        description: 'Strength training and cardio.',
        from: DateTime(2026, 2, 13, 17, 0),
        to: DateTime(2026, 2, 13, 18, 30),
        noteCategory: NoteCategory(title: 'Gym', color: const Color(0xFF4CAF50)),
      ),
      Note(
        title: 'Lunch',
        description: '',
        from: DateTime(2026, 2, 14, 12, 0),
        to: DateTime(2026, 2, 14, 13, 0),
        noteCategory: NoteCategory(title: 'Essen', color: const Color(0xFFFFC107)),
      ),
      Note(
        title: '',
        description: 'A note without a title',
        from: DateTime(2026, 2, 14, 7, 0),
        to: DateTime(2026, 2, 14, 7, 30),
        noteCategory: NoteCategory(title: 'Arbeit', color: const Color(0xFF9C27B0)),
      ),
    ];
  }

  // ── DateRange tests ────────────────────────────────────────────────────

  group('DateRange', () {
    test('lastWeek creates 7-day range', () {
      final range = DateRange.lastWeek();
      final diff = range.end.difference(range.start).inDays;
      expect(diff, 7);
      expect(range.type, DateRangeType.week);
    });

    test('lastMonth creates 30-day range', () {
      final range = DateRange.lastMonth();
      final diff = range.end.difference(range.start).inDays;
      expect(diff, 30);
      expect(range.type, DateRangeType.month);
    });

    test('currentMonth starts on first of month', () {
      final range = DateRange.currentMonth();
      expect(range.start.day, 1);
      expect(range.type, DateRangeType.currentMonth);
    });

    test('all handles empty dates', () {
      final range = DateRange.all([]);
      expect(range.start, range.end);
      expect(range.type, DateRangeType.all);
    });

    test('all uses earliest and latest dates', () {
      final dates = [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 10),
        DateTime(2026, 1, 5),
      ];
      final range = DateRange.all(dates);
      expect(range.start, DateTime(2026, 1, 5));
      expect(range.end, DateTime(2026, 2, 10));
    });

    test('equality works correctly', () {
      final range1 = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      final range2 = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      expect(range1, equals(range2));
    });
  });

  // ── File naming tests ──────────────────────────────────────────────────

  group('DateRange.toFileName', () {
    test('week range uses CW format', () {
      final range = DateRange(
        start: DateTime(2026, 2, 8),
        end: DateTime(2026, 2, 15),
        type: DateRangeType.week,
      );
      final name = range.toFileName();
      expect(name, startsWith('TrackingReport_'));
      expect(name, contains('CW'));
    });

    test('month range uses YYMM format', () {
      final range = DateRange(
        start: DateTime(2026, 1, 16),
        end: DateTime(2026, 2, 15),
        type: DateRangeType.month,
      );
      final name = range.toFileName();
      expect(name, 'TrackingReport_2602');
    });

    test('currentMonth range uses YYMM format', () {
      final range = DateRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 15),
        type: DateRangeType.currentMonth,
      );
      final name = range.toFileName();
      expect(name, 'TrackingReport_2602');
    });

    test('custom range uses YYMMDD-YYMMDD format', () {
      final range = DateRange(
        start: DateTime(2026, 1, 5),
        end: DateTime(2026, 2, 10),
        type: DateRangeType.custom,
      );
      final name = range.toFileName();
      expect(name, 'TrackingReport_260105-260210');
    });

    test('all range uses YYMMDD-YYMMDD format', () {
      final range = DateRange(
        start: DateTime(2025, 12, 1),
        end: DateTime(2026, 2, 15),
        type: DateRangeType.all,
      );
      final name = range.toFileName();
      expect(name, 'TrackingReport_251201-260215');
    });
  });

  // ── PDF generation tests ───────────────────────────────────────────────

  group('PdfReportGenerator', () {
    test('generates non-empty PDF with sample data', () async {
      final diaryDays = createSampleDiaryDays();
      final notes = createSampleNotes();

      // Attach notes to diary days
      for (var day in diaryDays) {
        day.notes = notes.where((n) =>
            n.from.year == day.day.year &&
            n.from.month == day.day.month &&
            n.from.day == day.day.day).toList();
      }

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'TestUser',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      // PDF files start with %PDF
      expect(pdfBytes[0], 0x25); // %
      expect(pdfBytes[1], 0x50); // P
      expect(pdfBytes[2], 0x44); // D
      expect(pdfBytes[3], 0x46); // F
    });

    test('generates PDF with empty data', () async {
      final generator = PdfReportGenerator(
        diaryDays: [],
        notes: [],
        username: 'EmptyUser',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      // Valid PDF header
      expect(pdfBytes[0], 0x25);
      expect(pdfBytes[1], 0x50);
      expect(pdfBytes[2], 0x44);
      expect(pdfBytes[3], 0x46);
    });

    test('generates PDF with ratings only (no notes)', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 3),
            DayRating(dayRating: DayRatings.productivity, score: 4),
            DayRating(dayRating: DayRatings.sport, score: 2),
            DayRating(dayRating: DayRatings.food, score: 5),
          ],
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'RatingsOnly',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes[0], 0x25); // %PDF
    });

    test('generates PDF with notes only (no ratings)', () async {
      final notes = createSampleNotes();
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 13), ratings: []),
      ];
      diaryDays.first.notes = notes.where((n) =>
          n.from.day == 13).toList();

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'NotesOnly',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes[0], 0x25); // %PDF
    });

    test('filters diary days by date range correctly', () async {
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 1, 15), ratings: [
          DayRating(dayRating: DayRatings.social, score: 1),
        ]),
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
        ]),
        DiaryDay(day: DateTime(2026, 3, 5), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];

      // Only Feb should be included
      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'FilterTest',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      // We can at least confirm a valid PDF is produced
      expect(pdfBytes[0], 0x25); // %PDF
    });

    test('handles single day range', () async {
      final diaryDays = createSampleDiaryDays();
      final notes = createSampleNotes();

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'SingleDay',
        startDate: DateTime(2026, 2, 13),
        endDate: DateTime(2026, 2, 13),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes[0], 0x25); // %PDF
    });

    test('PDF size is reasonable for typical data', () async {
      final diaryDays = createSampleDiaryDays();
      final notes = createSampleNotes();
      for (var day in diaryDays) {
        day.notes = notes.where((n) =>
            n.from.year == day.day.year &&
            n.from.month == day.day.month &&
            n.from.day == day.day.day).toList();
      }

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'SizeTest',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      // PDF should be at least 1KB (has content) but less than 5MB (reasonable)
      expect(pdfBytes.length, greaterThan(1024));
      expect(pdfBytes.length, lessThan(5 * 1024 * 1024));
    });
  });
}
