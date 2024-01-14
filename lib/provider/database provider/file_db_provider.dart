import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SimpleDiary/model/day/diary_day.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/services/database_services/diary_day_firestore_api.dart';
import 'package:SimpleDiary/services/database_services/note_firestore_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileDbProvider extends StateNotifier<List<DiaryDay>> {
  FileDbProvider() : super([]) {}

  Future<void> export(List<DiaryDay> diaryDays, File file) async {
    LogWrapper.logger.i('export started');
    List<Map<String, dynamic>> jsonList = diaryDays.map((obj) => obj.toMap()).toList();

    // Convert the list of maps to a JSON string
    String jsonString = jsonEncode(jsonList);

    // Write the JSON string to a file
    file.writeAsStringSync(jsonString);

    LogWrapper.logger.i('JSON file written successfully.');
  }

  Future<void> import(File file) async {
    LogWrapper.logger.t("import started");
    state = [];
    // Read the contents of the JSON file
    String jsonString = file.readAsStringSync();
    // Parse the JSON string into a list of maps
    List<dynamic> jsonList = jsonDecode(jsonString);

    // Convert the list of maps to a list of YourObject instances
    List<DiaryDay> diaryDays = jsonList.map((json) => DiaryDay.fromMap(json)).toList();

    state = [...diaryDays];
    LogWrapper.logger.t("import finished");
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

final fileDbStateProvider = StateNotifierProvider<FileDbProvider, List<DiaryDay>>((ref) {
  return FileDbProvider();
});
