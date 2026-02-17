import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';

class NoteAttachmentsLocalDbHelper extends LocalDbHelper {
  NoteAttachmentsLocalDbHelper({
    required super.tableName,
    required super.primaryKey,
    required super.dbFile,
  });

  @override
  Future<void> onCreateSqlTable() async {
    await database!.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            $primaryKey TEXT PRIMARY KEY,
            noteId TEXT NOT NULL,
            filePath TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            fileSize INTEGER NOT NULL DEFAULT 0
          )
          ''');
  }

  @override
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return NoteAttachment(
      id: elementMap['id'],
      noteId: elementMap['noteId'],
      filePath: elementMap['filePath'],
      createdAt: Utils.fromDateTimeString(elementMap['createdAt']),
      fileSize: elementMap['fileSize'] ?? 0,
    );
  }

  Future<List<NoteAttachment>> getAttachmentsForNote(String noteId) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    final List<Map<String, dynamic>> result = await database!.query(
      tableName,
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'createdAt ASC',
    );
    return result
        .map((map) => generateElementFromDbMap(map) as NoteAttachment)
        .toList();
  }

  Future<void> deleteAttachmentsForNote(String noteId) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    await database!.delete(
      tableName,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }
}
