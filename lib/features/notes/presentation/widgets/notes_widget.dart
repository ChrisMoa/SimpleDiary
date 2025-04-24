import 'package:day_tracker/features/notes/data/models/note_data_source.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class NotesWidget extends ConsumerStatefulWidget {
  const NotesWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends ConsumerState<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedNotes = ref.watch(notesOfSelecteDayProvider);
    if (selectedNotes.isEmpty) {
      return const Center(
        child: Text(
          'No Events found!',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      );
    }

    return SfCalendarTheme(
      data: SfCalendarThemeData(
        timeTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: NoteDataSource(ref.watch(notesLocalDataProvider)),
        initialDisplayDate: ref.read(noteSelectedDateProvider),
        appointmentBuilder: appointmentBuilder,
        headerHeight: 0,
        todayHighlightColor: Colors.black,
        selectionDecoration:
            BoxDecoration(color: Colors.red.withValues(alpha: 0.2)),
        onTap: (details) {
          if (details.appointments == null) {
            return;
          }
          ref
              .read(noteEditingPageProvider.notifier)
              .updateNote(details.appointments!.first);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NoteViewingPage(),
          ));
        },
      ),
    );
  }

  Widget appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails calendarAppointmentDetails) {
    final note = calendarAppointmentDetails.appointments.first;
    return Container(
      width: calendarAppointmentDetails.bounds.width,
      height: calendarAppointmentDetails.bounds.height,
      decoration: BoxDecoration(
        color: note.noteCategory.color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          note.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
