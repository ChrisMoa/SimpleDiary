import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:enough_icalendar/enough_icalendar.dart';

/// Converts between SimpleDiary Note objects and iCalendar VEvent objects
class IcsConverter {
  /// Convert a single Note to an ICS VEvent
  VEvent noteToIcsEvent(Note note) {
    final event = VEvent();

    // Set unique identifier
    event.uid = note.id ?? Utils.uuid.v4();

    // Set title and description
    event.summary = note.title;
    event.description = note.description;

    // Set creation timestamp
    event.timeStamp = DateTime.now().toUtc();

    // Set start and end times
    if (note.isAllDay) {
      // All-day events: use date only (time component is ignored)
      event.start = DateTime(note.from.year, note.from.month, note.from.day);
      event.end = DateTime(note.to.year, note.to.month, note.to.day);
    } else {
      // Timed events: convert to UTC
      event.start = note.from.toUtc();
      event.end = note.to.toUtc();
    }

    // Set category
    event.categories = [note.noteCategory.title];

    // Add custom property for category color (non-standard extension)
    final color = note.noteCategory.color;
    final colorValue = ((color.a * 255.0).round() & 0xff) << 24 |
        ((color.r * 255.0).round() & 0xff) << 16 |
        ((color.g * 255.0).round() & 0xff) << 8 |
        ((color.b * 255.0).round() & 0xff);
    final colorHex = colorValue.toRadixString(16).padLeft(8, '0');

    try {
      final colorProperty = TextProperty('X-CATEGORY-COLOR:#$colorHex');
      event.setProperty(colorProperty);
    } catch (e) {
      LogWrapper.logger.w('Could not set custom color property: $e');
    }

    return event;
  }

  /// Convert a list of Notes to a VCalendar
  VCalendar createCalendar(List<Note> notes) {
    final calendar = VCalendar();

    // Set calendar properties
    calendar.productId = '-//SimpleDiary//SimpleDiary Flutter App//EN';

    // Add all notes as events
    for (final note in notes) {
      try {
        final event = noteToIcsEvent(note);
        calendar.children.add(event);
      } catch (e) {
        LogWrapper.logger.e('Error converting note ${note.id} to ICS event: $e');
      }
    }

    LogWrapper.logger.i('Created ICS calendar with ${notes.length} events');
    return calendar;
  }

  /// Parse ICS VEvents to Note objects
  List<Note> icsEventsToNotes(VCalendar calendar) {
    final notes = <Note>[];

    // Get all VEvent children
    final events = calendar.children.whereType<VEvent>();

    if (events.isEmpty) {
      LogWrapper.logger.w('ICS calendar contains no events');
      return notes;
    }

    for (final event in events) {
      try {
        final note = _eventToNote(event);
        notes.add(note);
      } catch (e) {
        LogWrapper.logger.e('Error converting ICS event ${event.uid} to Note: $e');
      }
    }

    LogWrapper.logger.i('Parsed ${notes.length} notes from ICS calendar');
    return notes;
  }

  /// Convert a single VEvent to a Note
  Note _eventToNote(VEvent event) {
    // Extract basic properties
    final uid = event.uid;
    final title = event.summary ?? 'Untitled';
    final description = event.description ?? '';

    // Parse start and end times
    DateTime from;
    DateTime to;
    bool isAllDay = false;

    if (event.start != null) {
      from = event.start!;

      // Check if it's an all-day event by examining if time component is midnight
      // and comparing with end date
      if (event.end != null) {
        final startDate = DateTime(from.year, from.month, from.day);
        final endDate = DateTime(event.end!.year, event.end!.month, event.end!.day);

        // If times are at midnight and dates differ, it's likely all-day
        if (from.hour == 0 && from.minute == 0 &&
            event.end!.hour == 0 && event.end!.minute == 0 &&
            !startDate.isAtSameMomentAs(endDate)) {
          isAllDay = true;
          from = startDate;
        } else {
          // Convert from UTC to local time for timed events
          from = from.toLocal();
        }
      } else {
        from = from.toLocal();
      }
    } else {
      // No start time specified, use current time
      from = DateTime.now();
      LogWrapper.logger.w('Event $uid has no start time, using current time');
    }

    if (event.end != null) {
      to = event.end!;
      if (isAllDay) {
        to = DateTime(to.year, to.month, to.day);
      } else {
        to = to.toLocal();
      }
    } else {
      // No end time, default to 1 hour after start
      to = from.add(const Duration(hours: 1));
      LogWrapper.logger.w('Event $uid has no end time, using start + 1 hour');
    }

    // Map category
    NoteCategory noteCategory = availableNoteCategories.first;
    if (event.categories != null && event.categories!.isNotEmpty) {
      final categoryName = event.categories!.first;

      // Try to find matching category
      try {
        noteCategory = availableNoteCategories.firstWhere(
          (cat) => cat.title.toLowerCase() == categoryName.toLowerCase(),
          orElse: () {
            LogWrapper.logger.w(
              'Category "$categoryName" not found in availableNoteCategories, using default'
            );
            return availableNoteCategories.first;
          },
        );
      } catch (e) {
        LogWrapper.logger.w('Error mapping category: $e');
      }
    }

    return Note(
      id: uid ?? Utils.uuid.v4(),
      title: title,
      description: description,
      from: from,
      to: to,
      isAllDay: isAllDay,
      noteCategory: noteCategory,
    );
  }

  /// Convert VCalendar to ICS string format
  String calendarToString(VCalendar calendar) {
    return calendar.toString();
  }

  /// Parse ICS string to VCalendar
  VCalendar stringToCalendar(String icsString) {
    try {
      final component = VComponent.parse(icsString);
      if (component is VCalendar) {
        return component;
      } else {
        throw FormatException('Parsed component is not a VCalendar');
      }
    } catch (e) {
      LogWrapper.logger.e('Error parsing ICS string: $e');
      rethrow;
    }
  }
}
