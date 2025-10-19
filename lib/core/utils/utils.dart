import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Utils {
  static const dateTimePattern = 'dd.MM.yyyy HH:mm';
  static const _uuid = Uuid();

  static String toDateTime(DateTime dateTime) {
    final date = DateFormat(dateTimePattern).format(dateTime);
    return date;
  }

  static String toTimeFine(DateTime dateTime) {
    var pattern = 'dd.MM.yy HH:mm:ss.SSS';
    final date = DateFormat(pattern).format(dateTime);
    return date;
  }

  static String toFileDateTime(DateTime dateTime) {
    var pattern = 'yy-MM-dd_HH-mm';
    final date = DateFormat(pattern).format(dateTime);
    return date;
  }

  static DateTime fromDateTimeString(String dateTime) {
    DateFormat format = DateFormat(dateTimePattern);
    return format.parse(dateTime);
  }

  static String toDate(DateTime dateTime) {
    final date = DateFormat('dd.MM.yyyy').format(dateTime);
    return date;
  }

  static DateTime fromDate(String dateTime) {
    DateFormat format = DateFormat('dd.MM.yyyy');
    return format.parse(dateTime);
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);
    return time;
  }

  static DateTime removeTime(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  static int colorToRGBInt(Color color) {
    return ((color.alpha & 0xFF) << 24) | ((color.red & 0xFF) << 16) | ((color.green & 0xFF) << 8) | (color.blue & 0xFF);
  }

  static String printMonth(DateTime dateTime) {
    return DateFormat('MMM').format(dateTime);
  }

  static get uuid {
    return _uuid;
  }

  static bool isDateTimeWithinTimeSpan(DateTime dateTimeToCheck, DateTime startTime, DateTime endTime) {
    if (dateTimeToCheck == startTime || dateTimeToCheck == endTime) {
      return true;
    }

    return dateTimeToCheck.isAfter(startTime) && dateTimeToCheck.isBefore(endTime);
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+[{]}|;:,.<>?';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

