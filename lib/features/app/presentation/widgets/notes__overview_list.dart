import 'package:day_tracker/features/app/presentation/widgets/notes_overview_list_item.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesOverviewList extends ConsumerStatefulWidget {
  const NotesOverviewList({super.key});

  @override
  ConsumerState<NotesOverviewList> createState() => _NotesOverviewListState();
}

class _NotesOverviewListState extends ConsumerState<NotesOverviewList> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesLocalDataProvider);
    return notes.isEmpty ? _buildEmptyList() : _buildFilledList();
  }

  Widget _buildEmptyList() {
    return const Text("UUh, nothing here");
  }

  Widget _buildFilledList() {
    final notes = ref.read(notesLocalDataProvider);
    notes.sort((a, b) => b.from.compareTo(a.from));

    return ListView.builder(
      itemBuilder: (ctx, index) => NotesOverviewListItem(
        note: notes[index],
        onSelectNote: onSelectNote,
      ),
      itemCount: notes.length,
    );
  }

  void onSelectNote(Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const NoteViewingPage(),
    ));
  }
}
