import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for note search and filtering
class NoteSearchState {
  final String query;
  final NoteCategory? categoryFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool favoritesOnly;

  const NoteSearchState({
    this.query = '',
    this.categoryFilter,
    this.dateFrom,
    this.dateTo,
    this.favoritesOnly = false,
  });

  /// Returns true if any filter is active
  bool get isActive =>
      query.isNotEmpty ||
      categoryFilter != null ||
      dateFrom != null ||
      dateTo != null ||
      favoritesOnly;

  NoteSearchState copyWith({
    String? query,
    NoteCategory? Function()? categoryFilter,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    bool? favoritesOnly,
  }) {
    return NoteSearchState(
      query: query ?? this.query,
      categoryFilter:
          categoryFilter != null ? categoryFilter() : this.categoryFilter,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  /// Clear nullable fields helper
  NoteSearchState clearCategory() => copyWith(categoryFilter: () => null);
  NoteSearchState clearDateRange() =>
      copyWith(dateFrom: () => null, dateTo: () => null);
}

/// StateNotifier for managing search state
class NoteSearchProvider extends StateNotifier<NoteSearchState> {
  NoteSearchProvider() : super(const NoteSearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategoryFilter(NoteCategory? category) {
    state = state.copyWith(categoryFilter: () => category);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(
      dateFrom: () => from,
      dateTo: () => to,
    );
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  }

  void clearAll() {
    state = const NoteSearchState();
  }
}

/// Provider for search state
final noteSearchProvider =
    StateNotifierProvider<NoteSearchProvider, NoteSearchState>((ref) {
  return NoteSearchProvider();
});

/// Pure function for filtering notes (extracted for testability)
List<Note> filterNotes(List<Note> notes, NoteSearchState search) {
  if (!search.isActive) {
    // No filters active - return all notes sorted by date descending
    final sortedNotes = List<Note>.from(notes);
    sortedNotes.sort((a, b) => b.from.compareTo(a.from));
    return sortedNotes;
  }

  var filtered = notes.where((note) {
    // Favorites filter
    if (search.favoritesOnly && !note.isFavorite) {
      return false;
    }

    // Text search (case-insensitive) - search in title and description
    if (search.query.isNotEmpty) {
      final q = search.query.toLowerCase();
      final titleMatch = note.title.toLowerCase().contains(q);
      final descriptionMatch = note.description.toLowerCase().contains(q);
      if (!titleMatch && !descriptionMatch) {
        return false;
      }
    }

    // Category filter - match by title
    if (search.categoryFilter != null &&
        note.noteCategory.title != search.categoryFilter!.title) {
      return false;
    }

    // Date range filter
    if (search.dateFrom != null) {
      // Check if note starts before the dateFrom (at start of day)
      final fromDayStart = DateTime(
        search.dateFrom!.year,
        search.dateFrom!.month,
        search.dateFrom!.day,
      );
      if (note.from.isBefore(fromDayStart)) {
        return false;
      }
    }
    if (search.dateTo != null) {
      // Check if note starts after the dateTo (at end of day)
      final toDayEnd = DateTime(
        search.dateTo!.year,
        search.dateTo!.month,
        search.dateTo!.day,
        23,
        59,
        59,
      );
      if (note.from.isAfter(toDayEnd)) {
        return false;
      }
    }

    return true;
  }).toList();

  // Sort by date descending
  filtered.sort((a, b) => b.from.compareTo(a.from));
  return filtered;
}

/// Provider that combines search state with all notes to produce filtered results
final filteredNotesProvider = Provider<List<Note>>((ref) {
  final allNotes = ref.watch(notesLocalDataProvider);
  final search = ref.watch(noteSearchProvider);

  return filterNotes(allNotes, search);
});
