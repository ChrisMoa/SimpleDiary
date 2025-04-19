import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/data/models/note_data_source.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/notes/presentation/widgets/notes_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  @override
  Widget build(BuildContext context) {
    ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();
    ref.read(diaryDayLocalDbDataProvider.notifier).readObjectsFromDatabase();

    return SfCalendar(
      view: CalendarView.month,
      dataSource: NoteDataSource(ref.watch(notesLocalDataProvider)),
      initialSelectedDate: DateTime.now(),
      cellBorderColor: Colors.transparent,
      onLongPress: (details) {
        ref
            .read(noteSelectedDateProvider.notifier)
            .updateSelectedDate(details.date!);
        showModalBottomSheet(
          context: context,
          builder: (context) => const NotesWidget(),
        );
      },
      onTap: (details) {
        // set the selected Date
        final DateTime dtNow = DateTime.now();
        ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(DateTime(
            dtNow.year,
            dtNow.month,
            details.date!.day,
            dtNow.hour,
            dtNow.minute,
            dtNow.second,
            dtNow.microsecond));
      },
    );
  }
}
