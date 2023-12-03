import 'dart:io';

import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbHelper {
  late String dbName;
  String mainTableName;
  final String primaryKey;
  Database? database;

  LocalDbHelper({required this.mainTableName, required this.primaryKey, required}) {
    dbName = dotenv.env['LOCAL_DB_PATH'] ?? 'test.db';
  }

  initDatabase() async {
    if (database != null) {
      return;
    }
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    LogWrapper.logger.t('opens $dbName');
    database = await openDatabase(path, version: 1, onCreate: _onCreateDatabase);
    assert(database != null, '$dbName is not opened');
    await createSqlTable();
  }

  // creates a new sql table of the [tableName] inside the database
  Future<void> createSqlTable([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    var tableExists = await doesTableExist(tableName);
    if (tableExists) {
      return;
    }
    LogWrapper.logger.t('create table $tableName');
    await onCreateSqlTable();
  }

  Future _onCreateDatabase(Database db, int version) async {
    LogWrapper.logger.t('create database $dbName');
  }

  Future<bool> doesTableExist([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final List<Map<String, dynamic>> tables = await database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return tables.isNotEmpty;
  }

  Future<void> deleteTable([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    LogWrapper.logger.w('drops $tableName');
    await database!.execute('DROP TABLE IF EXISTS $tableName');
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<void> insert(LocalDbElement element, [String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final row = element.toLocalDbMap(element);
    await database!.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    return await database!.rawQuery('SELECT * FROM "$tableName"');
  }

  Future<int> queryRowCount([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    return Sqflite.firstIntValue(await database!.rawQuery('SELECT COUNT(*) FROM "$tableName"')) ?? 0;
  }

  Future<void> update(LocalDbElement element, [String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final row = element.toLocalDbMap(element);
    await database!.update(tableName, row, where: '$primaryKey = ?', whereArgs: [element.getId()]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<void> delete(LocalDbElement element, [String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    await database!.delete(tableName, where: '$primaryKey = ?', whereArgs: [element.getId()]);
  }

  Future<bool> checkIfElementExists(LocalDbElement element, [String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final List<Map<String, dynamic>> result = await database!.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [element.getId()],
    );

    return result.isNotEmpty;
  }

  Future<LocalDbElement> getElement(String id, [String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final List<Map<String, dynamic>> result = await database!.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
    assert(result.length == 1, 'invalid number of elements = ${result.length}');
    return generateElementFromDbMap(result.first);
  }

  Future<int> clearTable([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    return await database!.delete(tableName);
  }

  Future<List> getAllRecords([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    return await database!.rawQuery("SELECT * FROM $tableName");
  }

  // get a list of all stored objects converted
  Future<List<LocalDbElement>> getAllRecordsAsObject([String tableName = '']) async {
    assert(database != null, '$dbName is not opened');
    tableName.isEmpty ? tableName = mainTableName : tableName;
    final List<Map<String, dynamic>> records = await database!.rawQuery('SELECT * FROM "$tableName"');
    LogWrapper.logger.t('$tableName: got ${records.length} records');
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
