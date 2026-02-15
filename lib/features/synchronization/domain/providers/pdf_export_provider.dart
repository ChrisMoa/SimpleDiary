import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/synchronization/data/services/pdf_report_generator.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';

/// Date range model for PDF export
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// Last 7 days
  factory DateRange.lastWeek() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }

  /// Last 30 days
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  /// Current month
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  /// All time
  factory DateRange.all(List<DateTime> dates) {
    if (dates.isEmpty) {
      final now = DateTime.now();
      return DateRange(start: now, end: now);
    }
    dates.sort();
    return DateRange(start: dates.first, end: dates.last);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Provider for PDF report generation
final pdfExportProvider = FutureProvider.family<Uint8List, DateRange>(
  (ref, dateRange) async {
    final diaryDays = ref.read(diaryDayFullDataProvider);
    final notes = ref.read(notesLocalDataProvider);
    final username = settingsContainer.activeUserSettings.savedUserData.username;

    final generator = PdfReportGenerator(
      diaryDays: diaryDays,
      notes: notes,
      username: username,
      startDate: dateRange.start,
      endDate: dateRange.end,
    );

    return generator.generate();
  },
);
