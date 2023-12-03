import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_editing_page_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:flutter/material.dart';
import 'package:SimpleDiary/model/notes/note_data_source.dart';
import 'package:SimpleDiary/pages/note_viewing_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class NotesViewDayWidget extends ConsumerStatefulWidget {
  const NotesViewDayWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesViewDayWidgetState();
}

class _NotesViewDayWidgetState extends ConsumerState<NotesViewDayWidget> {
  @override
  Widget build(BuildContext context) {
    var notesOfDay = ref.watch(notesOfSelecteDayProvider);
    var selectedDate = ref.read(noteSelectedDateProvider);

    return SfCalendarTheme(
      data: SfCalendarThemeData(
        timeTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: NoteDataSource(notesOfDay),
        initialDisplayDate: selectedDate.copyWith(hour: 12),
        onSelectionChanged: (calendarSelectionDetails) {
          if (calendarSelectionDetails.date != null) {
            LogWrapper.logger.t('date: ${Utils.toDateTime(calendarSelectionDetails.date!)}');
            ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(calendarSelectionDetails.date!);
          }
        },
        appointmentBuilder: appointmentBuilder,
        minDate: selectedDate.copyWith(hour: 7),
        maxDate: selectedDate.copyWith(hour: 22),
        headerHeight: 0,
        todayHighlightColor: Colors.black,
        selectionDecoration: BoxDecoration(color: Colors.red.withOpacity(0.2)),
        onTap: (details) {
          if (details.appointments == null) {
            return;
          }
          ref.read(noteEditingPageProvider.notifier).updateNote(details.appointments!.first);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NoteViewingPage(),
          ));
        },
      ),
    );
  }

  Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails calendarAppointmentDetails) {
    final note = calendarAppointmentDetails.appointments.first;
    return Container(
      width: calendarAppointmentDetails.bounds.width,
      height: calendarAppointmentDetails.bounds.height,
      decoration: BoxDecoration(
        color: note.noteCategory.color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(note.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}
