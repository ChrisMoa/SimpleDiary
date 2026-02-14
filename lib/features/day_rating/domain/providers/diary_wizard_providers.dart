import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Selected date provider for the wizard
final wizardSelectedDateProvider =
    StateNotifierProvider<WizardSelectedDateNotifier, DateTime>(
  (ref) => WizardSelectedDateNotifier(ref),
);

class WizardSelectedDateNotifier extends StateNotifier<DateTime> {
  final Ref _ref;

  WizardSelectedDateNotifier(this._ref) : super(DateTime.now()) {
    // Initialize with the value from note_selected_date_provider
    state = _ref.read(noteSelectedDateProvider);

    // Listen for changes to ensure the providers stay in sync
    _ref.listen(noteSelectedDateProvider, (previous, next) {
      if (previous == null ||
          previous.day != next.day ||
          previous.month != next.month ||
          previous.year != next.year) {
        state = next;

        // Reset note selection when date changes
        _ref.read(selectedWizardNoteProvider.notifier).resetSelection();
        LogWrapper.logger.d('Date changed, resetting note selection');
      } else if (state != next) {
        // Update without resetting if only time changed
        state = next;
      }
    });
  }

  void updateSelectedDate(DateTime newDate) {
    final oldDate = state;

    // Determine if the date (day/month/year) is changing
    final dateChanging = oldDate.day != newDate.day ||
        oldDate.month != newDate.month ||
        oldDate.year != newDate.year;

    // Update state first
    state = newDate;

    // Also update the main selected date provider
    _ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(newDate);

    // If date portion changed, reset selection
    if (dateChanging) {
      // Give time for the notes list to update before resetting selection
      Future.microtask(() {
        _ref.read(selectedWizardNoteProvider.notifier).resetSelection();
        LogWrapper.logger.d('Date manually changed, resetting note selection');
      });
    }
  }
}

// Provider for notes of the selected day
final wizardDayNotesProvider = Provider<List<Note>>((ref) {
  final selectedDate = ref.watch(wizardSelectedDateProvider);
  final notes = ref.watch(notesLocalDataProvider);

  // Get notes for the selected day
  return notes.where((note) {
    return note.from.year == selectedDate.year &&
        note.from.month == selectedDate.month &&
        note.from.day == selectedDate.day;
  }).toList();
});

// Provider for the selected note in the wizard
final selectedWizardNoteProvider =
    StateNotifierProvider<SelectedNoteNotifier, Note?>(
  (ref) => SelectedNoteNotifier(ref),
);

class SelectedNoteNotifier extends StateNotifier<Note?> {
  final Ref _ref;

  SelectedNoteNotifier(this._ref) : super(null);

  void selectNote(Note note) {
    state = note;
  }

  void updateNote(Note oldNote, Note newNote) {
    if (state?.id == oldNote.id) {
      state = newNote;
    }
  }

  void clearSelection() {
    state = null;
  }

  void resetSelection() {
    // Clear current selection
    state = null;

    // Initialize with a note for the current date, if available
    final notes = _ref.read(wizardDayNotesProvider);

    if (notes.isNotEmpty) {
      // Try to find a non-empty note first
      final nonEmptyNotes = notes
          .where((note) => note.title.isNotEmpty || note.description.isNotEmpty)
          .toList();

      if (nonEmptyNotes.isNotEmpty) {
        state = nonEmptyNotes.first;
      } else {
        // If only empty notes exist, select the first one
        state = notes.first;
      }

      LogWrapper.logger.d('Selection reset to note: ${state?.id}');
    } else {
      LogWrapper.logger.d('Selection reset but no notes available');
    }
  }
}

// Provider for day ratings
final dayRatingsProvider =
    StateNotifierProvider<DayRatingsNotifier, List<DayRating>>(
  (ref) => DayRatingsNotifier(),
);

class DayRatingsNotifier extends StateNotifier<List<DayRating>> {
  DayRatingsNotifier()
      : super(
            // Initialize with default ratings
            DayRatings.values
                .map((type) => DayRating(dayRating: type, score: 3))
                .toList());

  void updateRating(DayRatings ratingType, int score) {
    state = state.map((rating) {
      if (rating.dayRating == ratingType) {
        return DayRating(dayRating: ratingType, score: score);
      }
      return rating;
    }).toList();
  }

  void resetRatings() {
    state = DayRatings.values
        .map((type) => DayRating(dayRating: type, score: 3))
        .toList();
  }
}

// Check if the day is fully scheduled (no time gaps)
final isDayFullyScheduledProvider = Provider<bool>((ref) {
  final selectedDate = ref.watch(wizardSelectedDateProvider);
  final notes = ref.watch(wizardDayNotesProvider);

  LogWrapper.logger.t(
      'Checking if day ${Utils.toDateTime(selectedDate)} is fully scheduled');

  // If there are no notes, the day is not fully scheduled
  if (notes.isEmpty) {
    return false;
  }

  // Define day boundaries
  final dayStart =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
  final dayEnd =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 22, 0);

  // Sort notes by start time
  notes.sort((a, b) => a.from.compareTo(b.from));

  // Check if the first note starts at or before dayStart
  if (notes.first.from.isAfter(dayStart)) {
    return false;
  }

  // Check if the last note ends at or after dayEnd
  if (notes.last.to.isBefore(dayEnd)) {
    return false;
  }

  // Check for gaps between notes
  for (int i = 0; i < notes.length - 1; i++) {
    if (notes[i].to.isBefore(notes[i + 1].from)) {
      return false;
    }
  }

  return true;
});

// Find the next available time slot in the day
final nextAvailableTimeSlotProvider = Provider<DateTime>((ref) {
  final selectedDate = ref.watch(wizardSelectedDateProvider);
  final notes = ref.watch(wizardDayNotesProvider);

  // Define day boundaries
  final dayStart =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
  final dayEnd =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 22, 0);

  // If there are no notes, start at the beginning of the day
  if (notes.isEmpty) {
    return dayStart;
  }

  // Sort notes by start time
  final sortedNotes = List<Note>.from(notes)
    ..sort((a, b) => a.from.compareTo(b.from));

  // Check for a gap at the beginning of the day
  if (sortedNotes.first.from.isAfter(dayStart)) {
    return dayStart;
  }

  // Check for gaps between notes
  for (int i = 0; i < sortedNotes.length - 1; i++) {
    if (sortedNotes[i].to.isBefore(sortedNotes[i + 1].from)) {
      return sortedNotes[i].to;
    }
  }

  // If no gaps found, use the end of the last note
  if (sortedNotes.last.to.isBefore(dayEnd)) {
    return sortedNotes.last.to;
  }

  // If the day is fully scheduled, return the start of the next day
  return DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day + 1, 7, 0);
});

// Provider for creating a new empty note
final createEmptyNoteProvider = Provider<Note>((ref) {
  ref.watch(wizardSelectedDateProvider);
  final nextAvailableTime = ref.watch(nextAvailableTimeSlotProvider);

  // Create a new note with default values
  return Note(
    title: '',
    description: '',
    from: nextAvailableTime,
    to: nextAvailableTime.add(const Duration(minutes: 30)),
    noteCategory: availableNoteCategories.first,
  );
});

// Provider for creating a note from a template
final createNoteFromTemplateProvider = Provider.family<Note, NoteTemplate>((ref, template) {
  ref.watch(wizardSelectedDateProvider);
  final nextAvailableTime = ref.watch(nextAvailableTimeSlotProvider);

  // Create a new note from the template
  return Note(
    title: template.title,
    description: template.generateDescription(),
    from: nextAvailableTime,
    to: nextAvailableTime.add(Duration(minutes: template.durationMinutes)),
    noteCategory: template.noteCategory,
  );
});

