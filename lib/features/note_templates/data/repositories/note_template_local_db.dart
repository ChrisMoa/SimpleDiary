import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';

class NoteTemplateLocalDb extends LocalDbHelper {
  NoteTemplateLocalDb({required tableName, required primaryKey, required dbFile})
      : super(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            $primaryKey TEXT PRIMARY KEY, 
            title TEXT NOT NULL, 
            description TEXT NOT NULL,
            durationMinutes INTEGER NOT NULL,
            noteCategory TEXT NOT NULL
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return NoteTemplate.fromEmpty().fromLocalDbMap(elementMap);
  }
}

