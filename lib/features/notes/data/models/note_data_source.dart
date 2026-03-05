import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class NoteDataSource extends CalendarDataSource {
  NoteDataSource(List<Note> appointments) {
    this.appointments = appointments;
  }

  Note getNote(int index) => appointments![index] as Note;

  @override
  DateTime getStartTime(int index) {
    return getNote(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return getNote(index).to;
  }

  @override
  String getSubject(int index) {
    return getNote(index).title;
  }

  @override
  bool isAllDay(int index) {
    return getNote(index).isAllDay;
  }

  @override
  Appointment convertToCalendarAppointment(dynamic customObject) {
    if (customObject is Note) {
      return customObject.convertToCalendarAppointment();
    }
    throw ArgumentError('Expected a Note object, got ${customObject.runtimeType}');
  }

  @override
  dynamic convertAppointmentToObject(dynamic customData, Appointment appointment) {
    if (customData is Note) {
      return customData.copyWith(
        from: _roundToNearest5Minutes(appointment.startTime),
        to: _roundToNearest5Minutes(appointment.endTime),
        isAllDay: appointment.isAllDay,
      );
    }
    return customData;
  }

  static DateTime _roundToNearest5Minutes(DateTime dt) {
    final rounded = (dt.minute / 5).round() * 5;
    return DateTime(dt.year, dt.month, dt.day, dt.hour + rounded ~/ 60, rounded % 60);
  }
}
