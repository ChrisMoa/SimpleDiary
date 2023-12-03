import 'dart:async';

import 'package:SimpleDiary/model/day/diary_day.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/services/database_services/diary_day_firestore_api.dart';
import 'package:SimpleDiary/services/database_services/note_firestore_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteDbProvider extends StateNotifier<List<DiaryDay>> {
  String? _token;
  late DiaryDayFirestoreAPI diaryDayDbHelper;
  late NotesFirestoreAPI noteDbHelper;
  int _numberOfDays = 1; // saves the maximum amount of days during upload or download, >0

  RemoteDbProvider() : super([]) {
    var projectId = dotenv.env['FIRESTORE_PROJECT_ID'] ?? '';
    if (projectId.isEmpty) {
      return;
    }
    String webApiKey = dotenv.env['FIRESTORE_API_KEY'] ?? '';
    bool isDebug = int.tryParse(dotenv.env['DEBUG_MODE'] ?? '1') == 1;
    var collectionNameDiaryDays = isDebug ? 'Test_DiaryDays' : 'DiaryDays';
    var collectionNameNotes = isDebug ? 'Test_Notes' : 'Notes';
    diaryDayDbHelper = DiaryDayFirestoreAPI(
      projectId: projectId,
      collectionName: collectionNameDiaryDays,
      webApiKey: webApiKey,
    );
    noteDbHelper = NotesFirestoreAPI(projectId: projectId, collectionName: collectionNameNotes, webApiKey: webApiKey);
  }

  set token(String token) {
    _token = token;
    noteDbHelper.idToken = token;
    diaryDayDbHelper.idToken = token;
  }

  double get progress {
    assert(_numberOfDays > 0, 'numberOfDays is $_numberOfDays');
    assert(state.length <= _numberOfDays, '(numberOfDays=$_numberOfDays|state.length=${state.length})');
    return state.length / _numberOfDays * 100;
  }

  Future<void> upload(List<DiaryDay> diaryDays) async {
    assert(_token != null && _token!.isNotEmpty, 'user is not logged in');
    //* stores the uploaded diaryDays in the state and updates every 333ms
    _numberOfDays = diaryDays.length;
    List<DiaryDay> dayChunk = [];
    Timer.periodic(const Duration(milliseconds: 333), (Timer timer) {
      state = [...state, ...dayChunk];
      dayChunk.clear();
    });

    for (var diaryDay in diaryDays) {
      for (var note in diaryDay.notes) {
        await noteDbHelper.update(note);
      }
      await diaryDayDbHelper.update(diaryDay);
      dayChunk.add(diaryDay);
    }

    LogWrapper.logger.t("upload started");
  }

  Future<void> download() async {
    // saves
    assert(_token != null && _token!.isNotEmpty, 'user is not logged in');

    LogWrapper.logger.t("download started");
    state = [];
    var diaryDays = (await diaryDayDbHelper.getAllRecordsAsObjects()).map((e) => e as DiaryDay);
    var notes = (await noteDbHelper.getAllRecordsAsObjects()).map((e) => e as Note);
    for (var diaryDay in diaryDays) {
      diaryDay.notes = notes.where((note) {
        return note.from.year == diaryDay.day.year && note.from.month == diaryDay.day.month && note.from.day == diaryDay.day.day;
      }).toList();
    }
    assert(diaryDays.isNotEmpty, 'no values found');
    LogWrapper.logger.t("download finished");
    state = [...diaryDays];
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final remoteDbStateProvider = StateNotifierProvider<RemoteDbProvider, List<DiaryDay>>((ref) {
  return RemoteDbProvider();
});
