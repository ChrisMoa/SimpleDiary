import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/database/local_db_helper.dart';
import 'package:SimpleDiary/model/day/diary_day.dart';

class DiaryDayLocalDbHelper extends LocalDbHelper {
  DiaryDayLocalDbHelper({required tableName, required primaryKey})
      : super(mainTableName: tableName, primaryKey: primaryKey);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute(
        'CREATE TABLE IF NOT EXISTS $mainTableName ($primaryKey TEXT PRIMARY KEY, ratings TEXT)');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return DiaryDay.fromEmpty().fromLocalDbMap(elementMap);
  }
}
