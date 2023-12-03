import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/provider/note_editing_page_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:SimpleDiary/widgets/calendar_widget.dart';
import 'package:SimpleDiary/pages/note_editing_page.dart';
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
        backgroundColor: Colors.red,
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
