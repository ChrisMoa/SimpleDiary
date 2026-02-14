import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';

class NoteTemplateLocalDb extends LocalDbHelper {
  NoteTemplateLocalDb({required tableName, required primaryKey, required dbFile})
      : super(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);

  @override
  Future<void> createSqlTable() async {
    await super.createSqlTable();

    // Migration: add column for existing databases (runs after table exists)
    try {
      await database!.execute(
        "ALTER TABLE $tableName ADD COLUMN descriptionSections TEXT NOT NULL DEFAULT ''",
      );
    } catch (_) {
      // Column already exists - expected for already-migrated databases
    }
  }

  @override
  Future<void> onCreateSqlTable() async {
    //* create table (fresh installs only)
    await database!.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            $primaryKey TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            durationMinutes INTEGER NOT NULL,
            noteCategory TEXT NOT NULL,
            descriptionSections TEXT NOT NULL DEFAULT ''
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return NoteTemplate.fromEmpty().fromLocalDbMap(elementMap);
  }
}
