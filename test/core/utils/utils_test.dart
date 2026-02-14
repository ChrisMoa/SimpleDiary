import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utils', () {
    group('toDateTime / fromDateTimeString', () {
      test('round-trip preserves date and time to minutes', () {
        final dateTime = DateTime(2024, 3, 15, 14, 30);
        final formatted = Utils.toDateTime(dateTime);
        final parsed = Utils.fromDateTimeString(formatted);
        expect(parsed.year, dateTime.year);
        expect(parsed.month, dateTime.month);
        expect(parsed.day, dateTime.day);
        expect(parsed.hour, dateTime.hour);
        expect(parsed.minute, dateTime.minute);
      });

      test('formats as dd.MM.yyyy HH:mm', () {
        final dateTime = DateTime(2024, 1, 5, 9, 7);
        final formatted = Utils.toDateTime(dateTime);
        expect(formatted, '05.01.2024 09:07');
      });

      test('handles midnight', () {
        final dateTime = DateTime(2024, 12, 31, 0, 0);
        final formatted = Utils.toDateTime(dateTime);
        final parsed = Utils.fromDateTimeString(formatted);
        expect(parsed.hour, 0);
        expect(parsed.minute, 0);
      });

      test('handles end of day', () {
        final dateTime = DateTime(2024, 6, 15, 23, 59);
        final formatted = Utils.toDateTime(dateTime);
        final parsed = Utils.fromDateTimeString(formatted);
        expect(parsed.hour, 23);
        expect(parsed.minute, 59);
      });
    });

    group('toDate / fromDate', () {
      test('round-trip preserves date', () {
        final dateTime = DateTime(2024, 7, 20);
        final formatted = Utils.toDate(dateTime);
        final parsed = Utils.fromDate(formatted);
        expect(parsed.year, dateTime.year);
        expect(parsed.month, dateTime.month);
        expect(parsed.day, dateTime.day);
      });

      test('formats as dd.MM.yyyy', () {
        final dateTime = DateTime(2024, 2, 14);
        final formatted = Utils.toDate(dateTime);
        expect(formatted, '14.02.2024');
      });
    });

    group('removeTime', () {
      test('strips time component', () {
        final dateTime = DateTime(2024, 5, 10, 15, 30, 45, 123);
        final dateOnly = Utils.removeTime(dateTime);
        expect(dateOnly.year, 2024);
        expect(dateOnly.month, 5);
        expect(dateOnly.day, 10);
        expect(dateOnly.hour, 0);
        expect(dateOnly.minute, 0);
        expect(dateOnly.second, 0);
        expect(dateOnly.millisecond, 0);
      });

      test('already midnight stays the same', () {
        final dateTime = DateTime(2024, 5, 10);
        final dateOnly = Utils.removeTime(dateTime);
        expect(dateOnly, dateTime);
      });
    });

    group('isSameDay', () {
      test('returns true for same day different times', () {
        final date1 = DateTime(2024, 3, 15, 8, 0);
        final date2 = DateTime(2024, 3, 15, 22, 30);
        expect(Utils.isSameDay(date1, date2), true);
      });

      test('returns false for different days', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 16);
        expect(Utils.isSameDay(date1, date2), false);
      });

      test('returns false for same day different months', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 4, 15);
        expect(Utils.isSameDay(date1, date2), false);
      });

      test('returns false for same day different years', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2025, 3, 15);
        expect(Utils.isSameDay(date1, date2), false);
      });
    });

    group('isDateTimeWithinTimeSpan', () {
      test('returns true when dateTime is within span', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 18, 0);
        final check = DateTime(2024, 1, 1, 14, 0);
        expect(Utils.isDateTimeWithinTimeSpan(check, start, end), true);
      });

      test('returns true when dateTime equals start', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 18, 0);
        expect(Utils.isDateTimeWithinTimeSpan(start, start, end), true);
      });

      test('returns true when dateTime equals end', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 18, 0);
        expect(Utils.isDateTimeWithinTimeSpan(end, start, end), true);
      });

      test('returns false when dateTime is before span', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 18, 0);
        final check = DateTime(2024, 1, 1, 8, 0);
        expect(Utils.isDateTimeWithinTimeSpan(check, start, end), false);
      });

      test('returns false when dateTime is after span', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 18, 0);
        final check = DateTime(2024, 1, 1, 20, 0);
        expect(Utils.isDateTimeWithinTimeSpan(check, start, end), false);
      });
    });

    group('generateRandomString', () {
      test('produces string of correct length', () {
        expect(Utils.generateRandomString(10).length, 10);
        expect(Utils.generateRandomString(0).length, 0);
        expect(Utils.generateRandomString(100).length, 100);
      });

      test('produces different strings on each call', () {
        final s1 = Utils.generateRandomString(20);
        final s2 = Utils.generateRandomString(20);
        expect(s1, isNot(equals(s2)));
      });
    });

    group('uuid', () {
      test('generates valid UUID v4 format', () {
        final id = Utils.uuid.v4();
        // UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );
        expect(uuidRegex.hasMatch(id), true);
      });

      test('generates unique UUIDs', () {
        final ids = List.generate(100, (_) => Utils.uuid.v4());
        expect(ids.toSet().length, 100);
      });
    });

    group('toTime', () {
      test('formats time as HH:mm', () {
        final dateTime = DateTime(2024, 1, 1, 14, 30);
        final time = Utils.toTime(dateTime);
        expect(time, contains('14'));
        expect(time, contains('30'));
      });
    });

    group('toFileDateTime', () {
      test('formats for file names', () {
        final dateTime = DateTime(2024, 3, 15, 14, 30);
        final formatted = Utils.toFileDateTime(dateTime);
        expect(formatted, '24-03-15_14-30');
      });
    });

    group('printMonth', () {
      test('returns abbreviated month name', () {
        final jan = DateTime(2024, 1, 15);
        expect(Utils.printMonth(jan), isNotEmpty);
      });
    });

    group('colorToRGBInt', () {
      test('converts color to ARGB integer', () {
        const color = Color(0xFF2196F3); // Material Blue
        final rgbInt = Utils.colorToRGBInt(color);
        // Should produce a valid int representation
        expect(rgbInt, isA<int>());
      });
    });
  });
}
