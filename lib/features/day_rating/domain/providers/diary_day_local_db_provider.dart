import 'package:day_tracker/core/database/db_provider_factory.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DiaryDay provider — migrated to schema-driven DbRepository.
final diaryDayLocalDbDataProvider = createDbProvider<DiaryDay>(
  tableName: DiaryDay.tableName,
  columns: DiaryDay.columns,
  fromMap: DiaryDay.fromDbMap,
  migrations: DiaryDay.migrations,
);

//-----------------------------------------------------------------------------------------------------------------------------------

final diaryDayFullDataProvider = Provider((ref) {
  final notes = ref.watch(notesLocalDataProvider);
  var diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  for (var diaryDay in diaryDays) {
    diaryDay.notes = notes.where((note) {
      return note.from.year == diaryDay.day.year &&
          note.from.month == diaryDay.day.month &&
          note.from.day == diaryDay.day.day;
    }).toList();
  }
  return diaryDays;
});

//-----------------------------------------------------------------------------------------------------------------------------------

final isDiaryOfDayCompleteProvider = Provider((ref) {
  final selectedDate = ref.watch(noteSelectedDateProvider);
  var diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final possibleDiaryDays = diaryDays.where((element) =>
      element.day.year == selectedDate.year &&
      element.day.month == selectedDate.month &&
      element.day.day == selectedDate.day);
  if (possibleDiaryDays.length > 1) {
    LogWrapper.logger.t(
        'found ${possibleDiaryDays.length} elements on day ${Utils.toDate(selectedDate)}');
  } else if (possibleDiaryDays.length == 1) {
    final diaryDay = possibleDiaryDays.first;
    return diaryDay.ratings.length == DayRatings.values.length;
  } else {
    return false;
  }
});
