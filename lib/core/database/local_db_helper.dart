import 'dart:io';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:sqflite/sqflite.dart';

class LocalDbHelper {
  File dbFile;
  String tableName;
  final String primaryKey;
  Database? database;

  LocalDbHelper(
      {required this.tableName,
      required this.primaryKey,
      required this.dbFile});

  initDatabase() async {
    // if (database != null) {
    //   LogWrapper.logger.t('${dbFile.path}-$tableName: alread exist');
    //   return;
    // }
    settingsContainer.applicationDocumentsPath;
    if (!dbFile.existsSync()) {
      LogWrapper.logger.t('creates database file ${dbFile.path}');
      dbFile.createSync(recursive: true);
    }

    LogWrapper.logger.t('opens ${dbFile.path}');
    database = await openDatabase(dbFile.path,
        version: 1, onCreate: _onCreateDatabase);
    assert(database != null, 'database of table "$tableName" is not opened');
    await createSqlTable();
  }

  // creates a new sql table of the [tableName] inside the database
  Future<void> createSqlTable() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    var tableExists = await doesTableExist();
    if (tableExists) {
      return;
    }
    LogWrapper.logger.t('create table $tableName');
    await onCreateSqlTable();
  }

  Future _onCreateDatabase(Database db, int version) async {
    LogWrapper.logger
        .i('create database file "${dbFile.path}" for table "$tableName"');
  }

  Future<bool> doesTableExist() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    final List<Map<String, dynamic>> tables = await database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return tables.isNotEmpty;
  }

  Future<void> deleteTable() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    LogWrapper.logger.w('drops $tableName');
    await database!.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Migrates the database by adding a new column if it doesn't exist
  /// This is useful for adding new fields to existing tables without losing data
  Future<void> migrateAddColumn(String columnName, String columnDef) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    try {
      await database!.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnDef',
      );
      LogWrapper.logger.i(
          'Migration: Added column $columnName to table $tableName');
    } catch (e) {
      // Column already exists, this is expected on subsequent runs
      LogWrapper.logger.d(
          'Migration: Column $columnName already exists in table $tableName');
    }
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<void> insert(LocalDbElement element) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    LogWrapper.logger.t('${dbFile.path}: insert note');
    final row = element.toLocalDbMap(element);
    await database!
        .insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Insert or replace: if a row with the same primary key exists, replace it.
  Future<void> insertOrReplace(LocalDbElement element) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    final row = element.toLocalDbMap(element);
    await database!
        .insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    return await database!.rawQuery('SELECT * FROM "$tableName"');
  }

  Future<int> queryRowCount() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    return Sqflite.firstIntValue(
            await database!.rawQuery('SELECT COUNT(*) FROM "$tableName"')) ??
        0;
  }

  Future<void> update(
    LocalDbElement element,
  ) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    LogWrapper.logger.t('${dbFile.path}: update note');
    final row = element.toLocalDbMap(element);
    await database!.update(tableName, row,
        where: '$primaryKey = ?', whereArgs: [element.getId()]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<void> delete(
    LocalDbElement element,
  ) async {
    assert(database != null, 'database of table "$tableName" is not opened');
    LogWrapper.logger.t('${dbFile.path}: delete note');
    await database!.delete(tableName,
        where: '$primaryKey = ?', whereArgs: [element.getId()]);
  }

  Future<bool> checkIfElementExists(
    LocalDbElement element,
  ) async {
    assert(database != null, 'database of table "$tableName" is not opened');

    final List<Map<String, dynamic>> result = await database!.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [element.getId()],
    );

    return result.isNotEmpty;
  }

  Future<LocalDbElement> getElement(String id) async {
    final List<Map<String, dynamic>> result = await database!.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
    assert(result.isNotEmpty,
        'User with $primaryKey $id not found in the database');
    return generateElementFromDbMap(result.first);
  }

  Future<int> clearTable() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    return await database!.delete(tableName);
  }

  Future<List> getAllRecords() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    return await database!.rawQuery("SELECT * FROM $tableName");
  }

  // get a list of all stored objects converted
  Future<List<LocalDbElement>> getAllRecordsAsObject() async {
    assert(database != null, 'database of table "$tableName" is not opened');
    final List<Map<String, dynamic>> records =
        await database!.rawQuery('SELECT * FROM "$tableName"');
    LogWrapper.logger
        .t('${dbFile.path}-$tableName: got ${records.length} records');
    if (records.isNotEmpty) {
      return List.generate(records.length, (index) {
        //? this way is a bit inefficient
        return generateElementFromDbMap(records[index]);
      });
    } else {
      return [];
    }
  }

  //! this methods has to be overwritten by the derived classes
  Future<void> onCreateSqlTable() async {
    throw UnimplementedError();
  }

  // generates a local db element from the given map (localDbElement can be e.g. a note)
  // this function exists because a direct conversion to the right class is not possible
  LocalDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    throw UnimplementedError();
  }
}
