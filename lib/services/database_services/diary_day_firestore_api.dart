import 'package:SimpleDiary/model/database/firestore_db_helper.dart';
import 'package:SimpleDiary/model/database/remote_db_element.dart';
import 'package:SimpleDiary/model/day/diary_day.dart';

class DiaryDayFirestoreAPI extends FirestoreDbHelper {
  DiaryDayFirestoreAPI(
      {required super.projectId,
      required super.collectionName,
      required super.webApiKey});

  @override
  RemoteDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return DiaryDay.fromEmpty().fromRemoteDbMap(elementMap);
  }
}
