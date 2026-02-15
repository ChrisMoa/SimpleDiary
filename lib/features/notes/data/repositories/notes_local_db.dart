import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';

class NotesLocalDbHelper extends LocalDbHelper {
  NotesLocalDbHelper({required tableName, required primaryKey, required dbFile})
      : super(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);

  @override
  Future<void> onCreateSqlTable() async {
    //* create table
    await database!.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            $primaryKey TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            fromDate TEXT NOT NULL,
            toDate TEXT NOT NULL,
            isAllDay INTEGER NOT NULL,
            noteCategory TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
          ''');
  }

  @override
  initDatabase() async {
    await super.initDatabase();
    // Migrate existing databases to add isFavorite column
    await migrateAddColumn('isFavorite', 'INTEGER NOT NULL DEFAULT 0');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return Note.fromEmpty().fromLocalDbMap(elementMap);
  }
}
