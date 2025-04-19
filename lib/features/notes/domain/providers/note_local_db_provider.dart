import 'package:day_tracker/core/database/abstract_local_db_provider_state.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/data/repositories/notes_local_db.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesLocalDataProvider extends AbstractLocalDbProviderState<Note> {
  NotesLocalDataProvider() : super(tableName: 'notes', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return NotesLocalDbHelper(
        tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final notesLocalDataProvider =
    StateNotifierProvider<NotesLocalDataProvider, List<Note>>((ref) {
  return NotesLocalDataProvider();
});

//-----------------------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------------------
final notesOfSelecteDayProvider = Provider((ref) {
  final selectedDate = ref.watch(noteSelectedDateProvider);
  final notes = ref.watch(notesLocalDataProvider);
  LogWrapper.logger
      .t('updates selectedDate to: ${Utils.toDateTime(selectedDate)}');

  return notes.where((element) {
    return element.from.year == selectedDate.year &&
        element.from.month == selectedDate.month &&
        element.from.day == selectedDate.day;
  }).toList();
});

//-----------------------------------------------------------------------------------------------------------------------------------

final nextFreeNoteOfSelectedDateProvider = Provider((ref) {
  final selectedDate = ref.watch(noteSelectedDateProvider);
  final notesOfDay = ref.watch(notesOfSelecteDayProvider);
  LogWrapper.logger.t('updates notes of day ${Utils.toDateTime(selectedDate)}');

  final dayBegin = selectedDate.copyWith(hour: 7, minute: 0, second: 0);
  final dayEnd = selectedDate.copyWith(hour: 22, minute: 0, second: 0);

  var timeIncrease = 15; // check 15minute chunks
  var curTime = dayBegin;
  var stop = notesOfDay.isEmpty;
  for (;
      curTime.isBefore(dayEnd) && !stop;
      curTime = curTime.add(Duration(minutes: timeIncrease))) {
    int timeSlotAtIndex = -1;
    for (final note in notesOfDay) {
      if (Utils.isDateTimeWithinTimeSpan(curTime, note.from, note.to)) {
        timeSlotAtIndex = notesOfDay.indexOf(note);
      }
    }
    if (timeSlotAtIndex == -1) {
      curTime = curTime.add(Duration(minutes: -timeIncrease));
      break;
    } else {
      curTime = notesOfDay[timeSlotAtIndex].to;
    }
  }
  if (curTime.isBefore(dayBegin)) {
    curTime = dayBegin;
  }
  var note = Note(
    title: '',
    description: '',
    from: curTime,
    to: curTime.add(const Duration(minutes: 30)),
    noteCategory: availableNoteCategories.first,
  );
  return note;
});

//-----------------------------------------------------------------------------------------------------------------------------------

final isDayFinishedProvider = Provider((ref) {
  final selectedDate = ref.watch(noteSelectedDateProvider);
  final notesOfDay = ref.watch(notesOfSelecteDayProvider);

  LogWrapper.logger.t(
      'updates day finished provider for day ${Utils.toDateTime(selectedDate)}');

  final dayBegin = selectedDate.copyWith(hour: 7, minute: 0, second: 0);
  final dayEnd = selectedDate.copyWith(hour: 22, minute: 0, second: 0);

  var timeIncrease = 15; // check 15minute chunks

  for (var curTime = dayBegin;
      curTime.isBefore(dayEnd);
      curTime = curTime.add(Duration(minutes: timeIncrease))) {
    bool found = false;
    for (final note in notesOfDay) {
      if (Utils.isDateTimeWithinTimeSpan(curTime, note.from, note.to)) {
        found = true;
        break;
      }
    }
    // time chunk not found -> can break
    if (!found) {
      return false;
    }
  }

  // all chunks are found -> return true
  return true;
});
