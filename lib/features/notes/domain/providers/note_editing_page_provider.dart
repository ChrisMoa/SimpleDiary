import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditingPageProvider extends StateNotifier<Note> {
  NoteEditingPageProvider() : super(Note.fromEmpty());

  void updateNote(Note newNote) {
    state = newNote;
  }
}

final noteEditingPageProvider =
    StateNotifierProvider<NoteEditingPageProvider, Note>(
  (ref) => NoteEditingPageProvider(),
);
