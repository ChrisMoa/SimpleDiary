import 'package:SimpleDiary/model/database/local_db_helper.dart';
import 'package:SimpleDiary/model/day/day_rating.dart';
import 'package:SimpleDiary/model/day/diary_day.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/abstract_local_db_provider_state.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:SimpleDiary/services/database_services/diary_day_local_db.dart';
import 'package:SimpleDiary/utils.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryDayDataProvider extends AbstractLocalDbProviderState<DiaryDay> {
  DiaryDayDataProvider() : super(tableName: 'diaryDays', primaryKey: 'day');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return DiaryDayLocalDbHelper(tableName: tableName, primaryKey: primaryKey);
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final diaryDayLocalDbDataProvider = StateNotifierProvider<DiaryDayDataProvider, List<DiaryDay>>((ref) {
  return DiaryDayDataProvider();
});

//-----------------------------------------------------------------------------------------------------------------------------------

final diaryDayFullDataProvider = Provider((ref) {
  final notes = ref.watch(notesLocalDataProvider);
  var diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  for (var diaryDay in diaryDays) {
    diaryDay.notes = notes.where((note) {
      return note.from.year == diaryDay.day.year && note.from.month == diaryDay.day.month && note.from.day == diaryDay.day.day;
    }).toList();
  }
  return diaryDays;
});

//-----------------------------------------------------------------------------------------------------------------------------------

final isDiaryOfDayCompleteProvider = Provider((ref) {
  final selectedDate = ref.watch(noteSelectedDateProvider);
  var diaryDays = ref.watch(diaryDayLocalDbDataProvider);
  final possibleDiaryDays = diaryDays.where((element) => element.day.year == selectedDate.year && element.day.month == selectedDate.month && element.day.day == selectedDate.day);
  if (possibleDiaryDays.length > 1) {
    LogWrapper.logger.t('found ${possibleDiaryDays.length} elements on day ${Utils.toDate(selectedDate)}');
  } else if (possibleDiaryDays.length == 1) {
    final diaryDay = possibleDiaryDays.first;
    return diaryDay.ratings.length == DayRatings.values.length;
  } else {
    return false;
  }
});
