import 'dart:io';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AbstractLocalDbProviderState<T extends LocalDbElement> extends StateNotifier<List<T>> {
  late LocalDbHelper helper;
  bool _databaseRead = false;
  String tableName;
  final String primaryKey;
  var _dbFile = File('${settingsContainer.applicationDocumentsPath}/empty.db');

  AbstractLocalDbProviderState({required this.tableName, required this.primaryKey}) : super([]) {
    helper = createLocalDbHelper(tableName, primaryKey);
    initDatabase();
  }

  File get dbFile {
    return _dbFile;
  }

  Future<void> initDatabase() async {
    if (_databaseRead) {
      return;
    }
    await helper.initDatabase();
  }

  Future<void> changeDbFileToUser(UserData userData) async {
    LogWrapper.logger.d('$tableName change db file to user "${userData.userId}"');
    if (userData.username.isEmpty) {
      return;
    }

    _dbFile = File('${settingsContainer.applicationDocumentsPath}/${userData.userId}.db');
    if (!_dbFile.existsSync()) {
      LogWrapper.logger.t('creates dbFile ${_dbFile.path}');
      _dbFile.createSync(recursive: true);
    }
  }

  Future<void> changeUser(UserData userData) async {
    if (userData.username.isEmpty) {
      LogWrapper.logger.d('log in as empty user');
      return;
    }
    LogWrapper.logger.d('$tableName change to user "${userData.userId}"');
    helper.dbFile = _dbFile;
    createLocalDbHelper(tableName, primaryKey);
    _databaseRead = false;
    await readObjectsFromDatabase();
  }

  Future<void> readObjectsFromDatabase() async {
    if (_databaseRead) {
      return;
    }
    await initDatabase();

    List<T> elements = [];
    var objectsFromDb = await helper.getAllRecordsAsObject();
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
    if (await helper.checkIfElementExists(element)) {
      return;
    }
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

  Future<void> clearTable() async {
    await helper.clearTable();
    if (tableName == helper.tableName) {
      // reset only in case of mainTable, others are helper tables
      state = [];
    }
  }

  Future<void> clearProvider() async {
    state = [];
  }

  @protected
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    throw UnimplementedError();
  }
}
