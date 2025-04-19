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
}
