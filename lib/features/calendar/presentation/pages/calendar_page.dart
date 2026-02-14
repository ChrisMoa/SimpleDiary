import 'package:day_tracker/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          const CalendarWidget(), // This trailing comma makes auto-formatting nicer for build methods.
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onPressed: () {
          var note = Note.fromEmpty();
          var date = ref.read(noteSelectedDateProvider);
          int m = 15 - date.minute % 15;
          note.from = date.add(Duration(minutes: m));
          note.to = note.from.add(const Duration(minutes: 30));
          ref.read(noteEditingPageProvider.notifier).updateNote(note);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NoteEditingPage(),
            ),
          );
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }
}
