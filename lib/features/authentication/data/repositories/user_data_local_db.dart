import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';

class UserDataLocalDb extends LocalDbHelper {
  UserDataLocalDb({required tableName, required primaryKey, required dbFile})
      : super(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute('''
          CREATE TABLE $tableName (
            $primaryKey TEXT PRIMARY KEY, 
            pin TEXT, 
            email TEXT,
            password TEXT,
            settings TEXT,
            userId TEXT NOT NULL
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return UserData.fromEmpty().fromLocalDbMap(elementMap);
  }
}
