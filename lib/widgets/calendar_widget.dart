import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:SimpleDiary/provider/user/remote_user_login_provider.dart';
import 'package:flutter/material.dart';
import 'package:SimpleDiary/model/notes/note_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:SimpleDiary/widgets/notes_widget.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(remoteUserLoginProvider),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(),
          ));
        }
        ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();
        ref
            .read(diaryDayLocalDbDataProvider.notifier)
            .readObjectsFromDatabase();

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
            ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(
                DateTime(dtNow.year, dtNow.month, details.date!.day, dtNow.hour,
                    dtNow.minute, dtNow.second, dtNow.microsecond));
          },
        );
      },
    );
  }
}
