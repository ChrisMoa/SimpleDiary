import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/database/local_db_helper.dart';
import 'package:SimpleDiary/model/user/user_data.dart';

class UserDataLocalDb extends LocalDbHelper {
  UserDataLocalDb({required tableName, required primaryKey})
      : super(mainTableName: tableName, primaryKey: primaryKey);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute('''
          CREATE TABLE $mainTableName (
            $primaryKey TEXT PRIMARY KEY, 
            pin TEXT, 
            email TEXT,
            password TEXT,
            apiKey TEXT,
            userId TEXT NOT NULL
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return UserData.fromEmpty().fromLocalDbMap(elementMap);
  }
}
