import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that filters notes to only favorites
final favoriteNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesLocalDataProvider);
  return notes
      .where((note) => note.isFavorite)
      .toList()
    ..sort((a, b) => b.from.compareTo(a.from)); // Most recent first
});

/// Count of favorite notes
final favoriteNotesCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteNotesProvider).length;
});
