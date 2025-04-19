import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';

class DiaryDayLocalDbHelper extends LocalDbHelper {
  DiaryDayLocalDbHelper(
      {required tableName, required primaryKey, required dbFile})
      : super(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute(
        'CREATE TABLE IF NOT EXISTS $tableName ($primaryKey TEXT PRIMARY KEY, ratings TEXT)');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return DiaryDay.fromEmpty().fromLocalDbMap(elementMap);
  }
}
