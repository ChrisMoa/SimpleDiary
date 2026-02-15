import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/synchronization/data/services/pdf_report_generator.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';

enum DateRangeType { week, month, currentMonth, custom, all }

/// Date range model for PDF export
class DateRange {
  final DateTime start;
  final DateTime end;
  final DateRangeType type;

  const DateRange({
    required this.start,
    required this.end,
    this.type = DateRangeType.custom,
  });

  /// Last 7 days
  factory DateRange.lastWeek() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
      type: DateRangeType.week,
    );
  }

  /// Last 30 days
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
      type: DateRangeType.month,
    );
  }

  /// Current month
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
      type: DateRangeType.currentMonth,
    );
  }

  /// Specific month
  factory DateRange.forMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0); // Last day of the month
    return DateRange(
      start: start,
      end: end,
      type: DateRangeType.currentMonth,
    );
  }

  /// Specific week (ISO week number)
  factory DateRange.forWeek(int year, int weekNumber) {
    // Calculate the date of the Monday of the given ISO week
    final jan4 = DateTime(year, 1, 4);
    final daysFromMonday = jan4.weekday - 1;
    final firstMonday = jan4.subtract(Duration(days: daysFromMonday));
    final weekStart = firstMonday.add(Duration(days: (weekNumber - 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return DateRange(
      start: weekStart,
      end: weekEnd,
      type: DateRangeType.week,
    );
  }

  /// All time
  factory DateRange.all(List<DateTime> dates) {
    if (dates.isEmpty) {
      final now = DateTime.now();
      return DateRange(start: now, end: now, type: DateRangeType.all);
    }
    dates.sort();
    return DateRange(
      start: dates.first,
      end: dates.last,
      type: DateRangeType.all,
    );
  }

  /// Generate a contextual file name based on range type
  String toFileName() {
    switch (type) {
      case DateRangeType.week:
        // Calendar week of the end date
        final weekNumber = _isoWeekNumber(end);
        final year = end.year % 100;
        return 'TrackingReport_${year.toString().padLeft(2, '0')}CW${weekNumber.toString().padLeft(2, '0')}';
      case DateRangeType.currentMonth:
        // Current month: YYMM format
        final year = end.year % 100;
        final month = end.month.toString().padLeft(2, '0');
        return 'TrackingReport_${year.toString().padLeft(2, '0')}$month';
      case DateRangeType.month:
        // Last 30 days: use date range format to distinguish from current month
        final startStr = _formatDateShort(start);
        final endStr = _formatDateShort(end);
        return 'TrackingReport_30d_$startStr-$endStr';
      case DateRangeType.custom:
      case DateRangeType.all:
        final startStr = _formatDateShort(start);
        final endStr = _formatDateShort(end);
        return 'TrackingReport_$startStr-$endStr';
    }
  }

  String _formatDateShort(DateTime date) {
    final year = (date.year % 100).toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekday = date.weekday;
    final woy = ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) return _isoWeekNumber(DateTime(date.year - 1, 12, 31));
    if (woy > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < 4) return 1;
    }
    return woy;
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
