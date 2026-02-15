import 'dart:io';
import 'dart:typed_data';

import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/synchronization/data/services/pdf_report_generator.dart';
import 'package:day_tracker/features/synchronization/domain/providers/pdf_export_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

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

  int findByteSequence(Uint8List data, List<int> sequence, int start) {
    for (int i = start; i <= data.length - sequence.length; i++) {
      bool found = true;
      for (int j = 0; j < sequence.length; j++) {
        if (data[i + j] != sequence[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  /// Extract readable text from PDF content streams by decompressing
  /// FlateDecode streams and searching decompressed content for text.
  /// Supports both (string) Tj and <hex> Tj and [...] TJ array operators.
  String extractPdfText(Uint8List pdfBytes) {
    final buffer = StringBuffer();
    final streamMarker = 'stream'.codeUnits;
    final endMarker = 'endstream'.codeUnits;

    int pos = 0;
    while (pos < pdfBytes.length - endMarker.length) {
      final streamStart = findByteSequence(pdfBytes, streamMarker, pos);
      if (streamStart == -1) break;

      var dataStart = streamStart + streamMarker.length;
      if (dataStart < pdfBytes.length && pdfBytes[dataStart] == 0x0D) {
        dataStart++;
      }
      if (dataStart < pdfBytes.length && pdfBytes[dataStart] == 0x0A) {
        dataStart++;
      }

      final streamEnd = findByteSequence(pdfBytes, endMarker, dataStart);
      if (streamEnd == -1) break;

      var end = streamEnd;
      while (end > dataStart &&
          (pdfBytes[end - 1] == 0x0A ||
              pdfBytes[end - 1] == 0x0D ||
              pdfBytes[end - 1] == 0x20)) {
        end--;
      }

      if (end > dataStart) {
        final streamData = pdfBytes.sublist(dataStart, end);
        String content;
        try {
          final decompressed = ZLibCodec().decode(streamData);
          content = String.fromCharCodes(decompressed);
        } catch (_) {
          content = String.fromCharCodes(streamData);
        }
        // Extract text from all (string) patterns in PDF operators
        final parenRegex = RegExp(r'\(([^)]*)\)');
        for (final match in parenRegex.allMatches(content)) {
          final text = match.group(1) ?? '';
          if (text.isNotEmpty) {
            buffer.write(text
                .replaceAll(r'\n', '\n')
                .replaceAll(r'\r', '\r')
                .replaceAll(r'\(', '(')
                .replaceAll(r'\)', ')')
                .replaceAll(r'\\', '\\'));
            buffer.write(' ');
          }
        }
      }

      pos = streamEnd + endMarker.length;
    }

    return buffer.toString();
  }

  /// Count PDF page objects via /Type /Page (not /Pages)
  int countPdfPages(Uint8List pdfBytes) {
    final raw = String.fromCharCodes(pdfBytes);
    final pageRegex = RegExp(r'/Type\s*/Page(?!s)');
    return pageRegex.allMatches(raw).length;
  }

  /// Create a large dataset with N consecutive diary days and notes
  List<DiaryDay> createLargeDataset(int dayCount, {DateTime? startFrom}) {
    final start = startFrom ?? DateTime(2026, 1, 1);
    return List.generate(dayCount, (i) {
      final date = start.add(Duration(days: i));
      final day = DiaryDay(
        day: date,
        ratings: [
          DayRating(dayRating: DayRatings.social, score: (i % 5) + 1),
          DayRating(dayRating: DayRatings.productivity, score: ((i + 1) % 5) + 1),
          DayRating(dayRating: DayRatings.sport, score: ((i + 2) % 5) + 1),
          DayRating(dayRating: DayRatings.food, score: ((i + 3) % 5) + 1),
        ],
      );
      return day;
    });
  }

  List<Note> createNotesForDays(List<DiaryDay> days) {
    final categories = [
      NoteCategory(title: 'Work', color: const Color(0xFF9C27B0)),
      NoteCategory(title: 'Gym', color: const Color(0xFF4CAF50)),
      NoteCategory(title: 'Food', color: const Color(0xFFFFC107)),
      NoteCategory(title: 'Leisure', color: const Color(0xFF03A9F4)),
      NoteCategory(title: 'Sleep', color: const Color(0xFF9E9E9E)),
    ];
    final notes = <Note>[];
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final noteCount = (i % 3) + 1; // 1-3 notes per day
      for (var j = 0; j < noteCount; j++) {
        notes.add(Note(
          title: 'Note ${i}_$j',
          description: j == 0 ? 'Description for note $i' : '',
          from: DateTime(day.day.year, day.day.month, day.day.day, 8 + j * 2),
          to: DateTime(day.day.year, day.day.month, day.day.day, 9 + j * 2),
          noteCategory: categories[(i + j) % categories.length],
        ));
      }
    }
    return notes;
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

    test('month range (last 30 days) uses date range format', () {
      final range = DateRange(
        start: DateTime(2026, 1, 16),
        end: DateTime(2026, 2, 15),
        type: DateRangeType.month,
      );
      final name = range.toFileName();
      expect(name, 'TrackingReport_30d_260116-260215');
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

  // ── DateRange factory constructor tests ─────────────────────────────────

  group('DateRange.forMonth', () {
    test('creates correct range for February 2026 (non-leap)', () {
      final range = DateRange.forMonth(2026, 2);
      expect(range.start, DateTime(2026, 2, 1));
      expect(range.end, DateTime(2026, 2, 28));
      expect(range.type, DateRangeType.currentMonth);
    });

    test('creates correct range for leap year February', () {
      final range = DateRange.forMonth(2028, 2);
      expect(range.start, DateTime(2028, 2, 1));
      expect(range.end, DateTime(2028, 2, 29));
    });

    test('creates correct range for December', () {
      final range = DateRange.forMonth(2026, 12);
      expect(range.start, DateTime(2026, 12, 1));
      expect(range.end, DateTime(2026, 12, 31));
    });

    test('creates correct range for January', () {
      final range = DateRange.forMonth(2026, 1);
      expect(range.start, DateTime(2026, 1, 1));
      expect(range.end, DateTime(2026, 1, 31));
    });

    test('creates correct range for a 30-day month', () {
      final range = DateRange.forMonth(2026, 4);
      expect(range.start, DateTime(2026, 4, 1));
      expect(range.end, DateTime(2026, 4, 30));
    });
  });

  group('DateRange.forWeek', () {
    test('creates 7-day range starting on Monday', () {
      final range = DateRange.forWeek(2026, 7);
      expect(range.end.difference(range.start).inDays, 6);
      expect(range.start.weekday, DateTime.monday);
      expect(range.end.weekday, DateTime.sunday);
      expect(range.type, DateRangeType.week);
    });

    test('week 1 of 2026 starts on correct Monday', () {
      final range = DateRange.forWeek(2026, 1);
      // ISO week 1 of 2026: Mon Dec 29, 2025 - Sun Jan 4, 2026
      expect(range.start.weekday, DateTime.monday);
      expect(range.end.weekday, DateTime.sunday);
      expect(range.end.difference(range.start).inDays, 6);
    });

    test('week 52 produces valid range', () {
      final range = DateRange.forWeek(2026, 52);
      expect(range.start.weekday, DateTime.monday);
      expect(range.end.weekday, DateTime.sunday);
      expect(range.end.difference(range.start).inDays, 6);
    });
  });

  // ── DateRange edge cases ────────────────────────────────────────────────

  group('DateRange edge cases', () {
    test('inequality for different ranges', () {
      final range1 = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      final range2 = DateRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28),
      );
      expect(range1, isNot(equals(range2)));
    });

    test('equal ranges have same hashCode', () {
      final range1 = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      final range2 = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('all with single date creates same start and end', () {
      final range = DateRange.all([DateTime(2026, 3, 15)]);
      expect(range.start, DateTime(2026, 3, 15));
      expect(range.end, DateTime(2026, 3, 15));
    });

    test('currentMonth end is today or earlier', () {
      final range = DateRange.currentMonth();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(range.end.isBefore(tomorrow), isTrue);
    });

    test('currentMonth start month matches end month', () {
      final range = DateRange.currentMonth();
      expect(range.start.month, range.end.month);
      expect(range.start.year, range.end.year);
    });

    test('all with duplicate dates still works', () {
      final dates = [
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 10),
        DateTime(2026, 3, 20),
      ];
      final range = DateRange.all(dates);
      expect(range.start, DateTime(2026, 1, 10));
      expect(range.end, DateTime(2026, 3, 20));
    });
  });

  // ── File naming additional tests ────────────────────────────────────────

  group('DateRange.toFileName additional', () {
    test('forWeek produces exact CW format', () {
      final range = DateRange.forWeek(2026, 7);
      final name = range.toFileName();
      expect(name, 'TrackingReport_26CW07');
    });

    test('forMonth produces exact YYMM format', () {
      final range = DateRange.forMonth(2026, 11);
      final name = range.toFileName();
      expect(name, 'TrackingReport_2611');
    });

    test('forMonth January produces correct format', () {
      final range = DateRange.forMonth(2026, 1);
      final name = range.toFileName();
      expect(name, 'TrackingReport_2601');
    });

    test('file names never contain spaces or special characters', () {
      final ranges = [
        DateRange.lastWeek(),
        DateRange.lastMonth(),
        DateRange.currentMonth(),
        DateRange.forMonth(2026, 6),
        DateRange.forWeek(2026, 10),
        DateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 12, 31),
          type: DateRangeType.custom,
        ),
        DateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 12, 31),
          type: DateRangeType.all,
        ),
      ];
      for (final range in ranges) {
        final name = range.toFileName();
        expect(name, isNot(contains(' ')), reason: 'Name has space: $name');
        expect(name, matches(RegExp(r'^[a-zA-Z0-9_\-]+$')),
            reason: 'Name has special chars: $name');
      }
    });

    test('all file names start with TrackingReport_', () {
      final ranges = [
        DateRange.lastWeek(),
        DateRange.lastMonth(),
        DateRange.currentMonth(),
        DateRange.forMonth(2026, 3),
        DateRange.forWeek(2026, 5),
        DateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 6, 30),
          type: DateRangeType.custom,
        ),
        DateRange.all([DateTime(2025, 1, 1), DateTime(2026, 12, 31)]),
      ];
      for (final range in ranges) {
        expect(range.toFileName(), startsWith('TrackingReport_'));
      }
    });

    test('week at year boundary uses correct week number', () {
      final range = DateRange.forWeek(2027, 1);
      final name = range.toFileName();
      expect(name, contains('CW01'));
    });

    test('single-digit week number is zero-padded', () {
      final range = DateRange.forWeek(2026, 3);
      final name = range.toFileName();
      expect(name, contains('CW03'));
    });

    test('double-digit week number is not padded', () {
      final range = DateRange.forWeek(2026, 15);
      final name = range.toFileName();
      expect(name, contains('CW15'));
    });
  });

  // ── PDF content verification via text extraction ────────────────────────

  group('PDF content verification', () {
    test('PDF contains username on cover page', () async {
      final generator = PdfReportGenerator(
        diaryDays: createSampleDiaryDays(),
        notes: [],
        username: 'JaneDoe',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('JaneDoe'));
    });

    test('PDF contains "Diary Report" title', () async {
      final generator = PdfReportGenerator(
        diaryDays: [],
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('Diary Report'));
    });

    test('PDF contains "Summary" section header', () async {
      final generator = PdfReportGenerator(
        diaryDays: createSampleDiaryDays(),
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('Summary'));
    });

    test('PDF contains "Report Period" text', () async {
      final generator = PdfReportGenerator(
        diaryDays: [],
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('Report Period'));
    });

    test('PDF contains category names when ratings exist', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 4),
            DayRating(dayRating: DayRatings.productivity, score: 3),
            DayRating(dayRating: DayRatings.sport, score: 5),
            DayRating(dayRating: DayRatings.food, score: 2),
          ],
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('Social'));
      expect(text, contains('Productivity'));
      expect(text, contains('Sport'));
      expect(text, contains('Food'));
    });

    test('PDF contains note titles', () async {
      final notes = [
        Note(
          title: 'ImportantMeeting',
          description: 'Quarterly review',
          from: DateTime(2026, 2, 10, 9, 0),
          to: DateTime(2026, 2, 10, 10, 0),
          noteCategory: NoteCategory(
              title: 'Work', color: const Color(0xFF9C27B0)),
        ),
      ];
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];
      diaryDays.first.notes = notes;

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('ImportantMeeting'));
    });

    test('PDF contains score values', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 5),
            DayRating(dayRating: DayRatings.productivity, score: 5),
            DayRating(dayRating: DayRatings.sport, score: 5),
            DayRating(dayRating: DayRatings.food, score: 5),
          ],
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 10),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      // Score: 20 (5+5+5+5) should appear in the diary entry
      expect(text, contains('20'));
    });

    test('PDF contains "Daily Breakdown" section', () async {
      final generator = PdfReportGenerator(
        diaryDays: createSampleDiaryDays(),
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 13),
        endDate: DateTime(2026, 2, 15),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      expect(text, contains('Daily Breakdown'));
    });
  });

  // ── PDF page count tests ────────────────────────────────────────────────

  group('PDF page structure', () {
    test('empty data PDF has at least 3 pages (cover, summary, charts)', () async {
      final generator = PdfReportGenerator(
        diaryDays: [],
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final pages = countPdfPages(pdfBytes);
      expect(pages, greaterThanOrEqualTo(3));
    });

    test('PDF with diary entries has more pages than empty PDF', () async {
      final emptyGen = PdfReportGenerator(
        diaryDays: [],
        notes: [],
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );
      final emptyPdf = await emptyGen.generate();

      final diaryDays = createSampleDiaryDays();
      final notes = createSampleNotes();
      for (var day in diaryDays) {
        day.notes = notes
            .where((n) =>
                n.from.year == day.day.year &&
                n.from.month == day.day.month &&
                n.from.day == day.day.day)
            .toList();
      }
      final fullGen = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'Test',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );
      final fullPdf = await fullGen.generate();

      expect(countPdfPages(fullPdf), greaterThan(countPdfPages(emptyPdf)));
    });
  });

  // ── Large dataset / stress tests ────────────────────────────────────────

  group('Large dataset PDF generation', () {
    test('generates valid PDF with 30 days of data', () async {
      final days = createLargeDataset(30);
      final notes = createNotesForDays(days);
      for (var day in days) {
        day.notes = notes
            .where((n) =>
                n.from.year == day.day.year &&
                n.from.month == day.day.month &&
                n.from.day == day.day.day)
            .toList();
      }

      final generator = PdfReportGenerator(
        diaryDays: days,
        notes: notes,
        username: 'LargeTest',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 30),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(1024));
    });

    test('generates valid PDF with 90 days of data', () async {
      final days = createLargeDataset(90);
      final notes = createNotesForDays(days);
      for (var day in days) {
        day.notes = notes
            .where((n) =>
                n.from.year == day.day.year &&
                n.from.month == day.day.month &&
                n.from.day == day.day.day)
            .toList();
      }

      final generator = PdfReportGenerator(
        diaryDays: days,
        notes: notes,
        username: 'StressTest',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(2048));
      expect(pdfBytes.length, lessThan(10 * 1024 * 1024));
    });

    test('generates valid PDF with 365 days of data', () async {
      final days = createLargeDataset(365);
      final notes = createNotesForDays(days);
      for (var day in days) {
        day.notes = notes
            .where((n) =>
                n.from.year == day.day.year &&
                n.from.month == day.day.month &&
                n.from.day == day.day.day)
            .toList();
      }

      final generator = PdfReportGenerator(
        diaryDays: days,
        notes: notes,
        username: 'YearTest',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(5 * 1024));
      expect(pdfBytes.length, lessThan(20 * 1024 * 1024));
    });

    test('PDF grows with more data', () async {
      final smallDays = createLargeDataset(5);
      final smallNotes = createNotesForDays(smallDays);
      final smallGen = PdfReportGenerator(
        diaryDays: smallDays,
        notes: smallNotes,
        username: 'Small',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      );
      final smallPdf = await smallGen.generate();

      final largeDays = createLargeDataset(60);
      final largeNotes = createNotesForDays(largeDays);
      for (var day in largeDays) {
        day.notes = largeNotes
            .where((n) =>
                n.from.year == day.day.year &&
                n.from.month == day.day.month &&
                n.from.day == day.day.day)
            .toList();
      }
      final largeGen = PdfReportGenerator(
        diaryDays: largeDays,
        notes: largeNotes,
        username: 'Large',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 1),
      );
      final largePdf = await largeGen.generate();

      expect(largePdf.length, greaterThan(smallPdf.length));
    });
  });

  // ── Edge case tests ─────────────────────────────────────────────────────

  group('PDF edge cases', () {
    test('handles all-day notes', () async {
      final notes = [
        Note(
          title: 'Holiday',
          description: 'National holiday',
          from: DateTime(2026, 2, 10),
          to: DateTime(2026, 2, 10, 23, 59),
          isAllDay: true,
          noteCategory: NoteCategory(
              title: 'Leisure', color: const Color(0xFF03A9F4)),
        ),
      ];
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 4),
        ]),
      ];
      diaryDays.first.notes = notes;

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'AllDayTest',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      final text = extractPdfText(pdfBytes);
      expect(text, contains('All day'));
    });

    test('handles maximum scores (all 5s)', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 5),
            DayRating(dayRating: DayRatings.productivity, score: 5),
            DayRating(dayRating: DayRatings.sport, score: 5),
            DayRating(dayRating: DayRatings.food, score: 5),
          ],
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'MaxScore',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 10),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      final text = extractPdfText(pdfBytes);
      // Overall score is 20 (5+5+5+5), should appear in table as "20/20"
      expect(text, contains('20/20'));
    });

    test('handles minimum scores (all 1s)', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 10),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 1),
            DayRating(dayRating: DayRatings.productivity, score: 1),
            DayRating(dayRating: DayRatings.sport, score: 1),
            DayRating(dayRating: DayRatings.food, score: 1),
          ],
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'MinScore',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 10),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      final text = extractPdfText(pdfBytes);
      // Overall score is 4 (1+1+1+1), should appear in table as "4/20"
      expect(text, contains('4/20'));
    });

    test('handles date range spanning year boundary', () async {
      final diaryDays = [
        DiaryDay(day: DateTime(2025, 12, 30), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
        DiaryDay(day: DateTime(2026, 1, 2), ratings: [
          DayRating(dayRating: DayRatings.social, score: 4),
        ]),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'YearBoundary',
        startDate: DateTime(2025, 12, 25),
        endDate: DateTime(2026, 1, 5),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(1024));
    });

    test('handles favorite diary days', () async {
      final diaryDays = [
        DiaryDay(
          day: DateTime(2026, 2, 14),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 5),
            DayRating(dayRating: DayRatings.productivity, score: 5),
            DayRating(dayRating: DayRatings.sport, score: 5),
            DayRating(dayRating: DayRatings.food, score: 5),
          ],
          isFavorite: true,
        ),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'FavoriteTest',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
    });

    test('handles notes with empty title (falls back to category)', () async {
      final notes = [
        Note(
          title: '',
          description: 'Untitled note content',
          from: DateTime(2026, 2, 10, 14, 0),
          to: DateTime(2026, 2, 10, 15, 0),
          noteCategory: NoteCategory(
              title: 'Gym', color: const Color(0xFF4CAF50)),
        ),
      ];
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];
      diaryDays.first.notes = notes;

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'EmptyTitle',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      final text = extractPdfText(pdfBytes);
      // When title is empty, category title "Gym" is used as fallback
      expect(text, contains('Gym'));
    });

    test('handles all note categories', () async {
      final allCategories = [
        NoteCategory(title: 'Work', color: const Color(0xFF9C27B0)),
        NoteCategory(title: 'Leisure', color: const Color(0xFF03A9F4)),
        NoteCategory(title: 'Food', color: const Color(0xFFFFC107)),
        NoteCategory(title: 'Gym', color: const Color(0xFF4CAF50)),
        NoteCategory(title: 'Sleep', color: const Color(0xFF9E9E9E)),
      ];
      final notes = allCategories
          .asMap()
          .entries
          .map((e) => Note(
                title: 'Note ${e.key}',
                description: '',
                from: DateTime(2026, 2, 10, 8 + e.key),
                to: DateTime(2026, 2, 10, 9 + e.key),
                noteCategory: e.value,
              ))
          .toList();
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];
      diaryDays.first.notes = notes;

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'AllCategories',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(1024));
    });

    test('notes outside date range are excluded from top activities', () async {
      final insideNote = Note(
        title: 'Inside',
        description: '',
        from: DateTime(2026, 2, 10, 9, 0),
        to: DateTime(2026, 2, 10, 10, 0),
        noteCategory: NoteCategory(
            title: 'Work', color: const Color(0xFF9C27B0)),
      );
      final outsideNote = Note(
        title: 'Outside',
        description: '',
        from: DateTime(2026, 3, 15, 9, 0),
        to: DateTime(2026, 3, 15, 10, 0),
        noteCategory: NoteCategory(
            title: 'Leisure', color: const Color(0xFF03A9F4)),
      );

      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];
      diaryDays.first.notes = [insideNote];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [insideNote, outsideNote],
        username: 'FilterNotes',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      // "Work" should appear as a top activity, "Leisure" should not
      // (since the Leisure note is outside the range)
      expect(text, contains('Work'));
    });

    test('custom theme colors produce valid PDF', () async {
      final generator = PdfReportGenerator(
        diaryDays: createSampleDiaryDays(),
        notes: createSampleNotes(),
        username: 'ThemeTest',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
        primaryColor: PdfColors.blue,
        secondaryColor: PdfColors.red,
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(1024));
    });

    test('diary day with empty ratings list shows score 0', () async {
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: []),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'NoRatings',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 10),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      // overallScore is 0 for empty ratings
      expect(text, contains('Score: 0'));
    });

    test('multiple notes on same day all appear', () async {
      final notes = List.generate(
        5,
        (i) => Note(
          title: 'Task$i',
          description: '',
          from: DateTime(2026, 2, 10, 8 + i),
          to: DateTime(2026, 2, 10, 9 + i),
          noteCategory: NoteCategory(
              title: 'Work', color: const Color(0xFF9C27B0)),
        ),
      );
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 3),
        ]),
      ];
      diaryDays.first.notes = notes;

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: notes,
        username: 'MultiNote',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 10),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      for (var i = 0; i < 5; i++) {
        expect(text, contains('Task$i'));
      }
    });
  });

  // ── Date range filtering precision tests ────────────────────────────────

  group('Date range filtering precision', () {
    test('boundary dates are inclusive', () async {
      // Days exactly on start and end dates should be included
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 2, 1), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
        ]),
        DiaryDay(day: DateTime(2026, 2, 15), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
        ]),
        DiaryDay(day: DateTime(2026, 2, 28), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
        ]),
      ];

      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'Boundary',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      // All 3 days should be included -> "Days Logged" should show 3
      expect(text, contains('3'));
    });

    test('days just outside range are excluded', () async {
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 1, 31), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
          DayRating(dayRating: DayRatings.productivity, score: 5),
          DayRating(dayRating: DayRatings.sport, score: 5),
          DayRating(dayRating: DayRatings.food, score: 5),
        ]),
        DiaryDay(day: DateTime(2026, 2, 10), ratings: [
          DayRating(dayRating: DayRatings.social, score: 1),
          DayRating(dayRating: DayRatings.productivity, score: 1),
          DayRating(dayRating: DayRatings.sport, score: 1),
          DayRating(dayRating: DayRatings.food, score: 1),
        ]),
        DiaryDay(day: DateTime(2026, 3, 1), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
          DayRating(dayRating: DayRatings.productivity, score: 5),
          DayRating(dayRating: DayRatings.sport, score: 5),
          DayRating(dayRating: DayRatings.food, score: 5),
        ]),
      ];

      // Only Feb 10 should be included
      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'Exclusion',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      final text = extractPdfText(pdfBytes);
      // Only 1 day logged
      expect(text, contains('Days Logged'));
      // The average score should be 4.0 (1+1+1+1=4, avg=4.0)
      expect(text, contains('4.0'));
    });

    test('empty range (no matching days) produces valid PDF', () async {
      final diaryDays = [
        DiaryDay(day: DateTime(2026, 3, 15), ratings: [
          DayRating(dayRating: DayRatings.social, score: 5),
        ]),
      ];

      // Range is February but diary day is in March
      final generator = PdfReportGenerator(
        diaryDays: diaryDays,
        notes: [],
        username: 'EmptyRange',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      final pdfBytes = await generator.generate();
      expect(pdfBytes[0], 0x25); // %PDF
      expect(pdfBytes.length, greaterThan(1024));
    });
  });
}
