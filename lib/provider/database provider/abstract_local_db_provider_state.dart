import 'package:SimpleDiary/model/database/local_db_element.dart';
import 'package:SimpleDiary/model/database/local_db_helper.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AbstractLocalDbProviderState<T extends LocalDbElement> extends StateNotifier<List<T>> {
  late LocalDbHelper helper;
  bool _databaseRead = false;
  String tableName;
  final String primaryKey;
  final String splitChars = '_';

  AbstractLocalDbProviderState({required this.tableName, required this.primaryKey}) : super([]) {
    tableName = 'default$splitChars$tableName'; //! tableName should not constist of any further numbers
    helper = createLocalDbHelper(tableName, primaryKey);
    initDatabase();
  }

  Future<void> initDatabase() async {
    if (_databaseRead) {
      return;
    }
    await helper.initDatabase();
  }

  Future<void> changeUser(UserData userData) async {
    // tableName = [user_name + 'originalTableName']
    var tableNameParts = tableName.split(splitChars);
    if (tableNameParts.length != 2) {
      return;
    }
    tableName = '${userData.username}$splitChars${tableNameParts[1]}';
    LogWrapper.logger.t('change table to $tableName');
    helper.mainTableName = tableName;
    _databaseRead = false;
    await readObjectsFromDatabase();
  }

  Future<void> readObjectsFromDatabase() async {
    if (_databaseRead) {
      return;
    }
    await initDatabase();

    List<T> elements = [];
    var objectsFromDb = await helper.getAllRecordsAsObject(helper.mainTableName);
    if (objectsFromDb.isEmpty) {
      LogWrapper.logger.t('$tableName is empty');
      _databaseRead = true;
      return;
    }
    assert(objectsFromDb.first is T, 'conversion error at element');
    for (var element in objectsFromDb) {
      elements.add(element as T);
    }
    state = elements;
    _databaseRead = true;
  }

  Future<void> addElement(LocalDbElement element) async {
    assert(element is T, 'conversion error at element');
    await helper.insert(element);
    state = [...state, element as T];
  }

  Future<void> deleteElement(LocalDbElement element) async {
    await helper.delete(element);
    state = state.where((curElement) => curElement.getId() != element.getId()).toList();
  }

  Future<void> editElement(LocalDbElement newElement, LocalDbElement oldElement) async {
    assert(newElement is T && oldElement is T, 'conversion error at element');
    await helper.update(newElement);
    state = state.map((curElement) => curElement.getId() == oldElement.getId() ? newElement as T : curElement).toList();
  }

  Future<void> clearTable([String tableName = '']) async {
    tableName.isEmpty ? tableName = this.tableName : tableName;
    await helper.clearTable(tableName);
    if (tableName == helper.mainTableName) {
      // reset only in case of mainTable, others are helper tables
      state = [];
    }
  }

  Future<void> copyTable(String newTableName) async {
    LogWrapper.logger.t('start to copy table to $newTableName');
    await helper.createSqlTable(newTableName);
    LogWrapper.logger.t('inserts elements to table $newTableName');
    for (var element in state) {
      await helper.insert(element);
    }
  }

  @protected
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    throw UnimplementedError();
  }
}
