import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/database/local_db_helper.dart';
import 'package:SimpleDiary/model/day/diary_day.dart';

class DiaryDayLocalDbHelper extends LocalDbHelper {
  DiaryDayLocalDbHelper({required tableName, required primaryKey, required dbFile})
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
