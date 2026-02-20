import 'dart:io';

import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

/// Unified repository that replaces both [LocalDbHelper] and
/// [AbstractLocalDbProviderState].
///
/// A single class handles:
/// - Schema-driven table creation via [columns]
/// - Versioned migrations via [migrations]
/// - Full CRUD operations
/// - Riverpod state management (extends [StateNotifier])
///
/// Usage:
/// ```dart
/// final provider = createDbProvider<MyEntity>(
///   tableName: 'my_entities',
///   columns: MyEntity.columns,
///   fromMap: MyEntity.fromDbMap,
/// );
/// ```
class DbRepository<T extends DbEntity> extends StateNotifier<List<T>> {
  final String tableName;
  final List<DbColumn> columns;
  final T Function(Map<String, dynamic> map) fromMap;
  final List<DbMigration> migrations;
  final List<String> additionalSql;

  Database? _database;
  bool _databaseRead = false;
  File _dbFile;

  /// The primary key column name, derived from [columns].
  late final String primaryKey;

  DbRepository({
    required this.tableName,
    required this.columns,
    required this.fromMap,
    this.migrations = const [],
    this.additionalSql = const [],
  })  : _dbFile = File(
            '${settingsContainer.applicationDocumentsPath}/empty.db'),
        super([]) {
    primaryKey = columns.firstWhere((c) => c.isPrimaryKey).name;
    _init();
  }

  File get dbFile => _dbFile;

  /// Expose database for custom queries in subclasses.
  @protected
  Database? get database => _database;

  // ── Lifecycle ────────────────────────────────────────────────────

  Future<void> _init() async {
    await initDatabase();
  }

  Future<void> initDatabase() async {
    if (_databaseRead) return;

    if (!_dbFile.existsSync()) {
      LogWrapper.logger.t('creates database file ${_dbFile.path}');
      _dbFile.createSync(recursive: true);
    }

    LogWrapper.logger.t('opens ${_dbFile.path}');
    _database = await openDatabase(_dbFile.path, version: 1);

    await _createTableIfNeeded();
    await _runMigrations();
  }

  Future<void> _createTableIfNeeded() async {
    final tables = await _database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    if (tables.isEmpty) {
      LogWrapper.logger.t('create table $tableName');
      final sql = DbColumn.createTableSql(tableName, columns);
      await _database!.execute(sql);
      for (final extra in additionalSql) {
        await _database!.execute(extra);
      }
    }
  }

  Future<void> _runMigrations() async {
    final sorted = List<DbMigration>.from(migrations)
      ..sort((a, b) => a.version.compareTo(b.version));
    for (final migration in sorted) {
      await migration.execute(_database!, tableName);
    }
  }

  // ── User switching (per-user database files) ─────────────────────

  Future<void> changeDbFileToUser(UserData userData) async {
    LogWrapper.logger
        .d('$tableName change db file to user "${userData.userId}"');
    if (userData.username.isEmpty) return;

    _dbFile = File(
      '${settingsContainer.applicationDocumentsPath}/${userData.userId}.db',
    );
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
    _databaseRead = false;
    _database = null;
    await readObjectsFromDatabase();
  }

  // ── Read ─────────────────────────────────────────────────────────

  Future<void> readObjectsFromDatabase() async {
    if (_databaseRead) return;
    await initDatabase();

    final records =
        await _database!.rawQuery('SELECT * FROM "$tableName"');
    LogWrapper.logger
        .t('${_dbFile.path}-$tableName: got ${records.length} records');

    if (records.isEmpty) {
      LogWrapper.logger.t('$tableName is empty');
      _databaseRead = true;
      return;
    }

    state = records.map((r) => fromMap(r)).toList();
    _databaseRead = true;
  }

  /// Force reload all data from the database into state.
  Future<void> reloadFromDatabase() async {
    await initDatabase();
    final records =
        await _database!.rawQuery('SELECT * FROM "$tableName"');
    LogWrapper.logger
        .d('$tableName reloaded ${records.length} elements from DB');
    state = records.map((r) => fromMap(r)).toList();
  }

  // ── Create ───────────────────────────────────────────────────────

  Future<void> addElement(T element) async {
    final exists = await _elementExists(element);
    if (exists) return;

    await _database!.insert(
      tableName,
      element.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    state = [...state, element];
  }

  Future<void> addOrUpdateElement(T element) async {
    await _database!.insert(
      tableName,
      element.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final existsInState =
        state.any((cur) => cur.primaryKeyValue == element.primaryKeyValue);
    if (existsInState) {
      state = state
          .map((cur) =>
              cur.primaryKeyValue == element.primaryKeyValue ? element : cur)
          .toList();
    } else {
      state = [...state, element];
    }
  }

  // ── Update ───────────────────────────────────────────────────────

  Future<void> editElement(T newElement, T oldElement) async {
    await _database!.update(
      tableName,
      newElement.toDbMap(),
      where: '$primaryKey = ?',
      whereArgs: [oldElement.primaryKeyValue],
    );
    state = state
        .map((cur) =>
            cur.primaryKeyValue == oldElement.primaryKeyValue ? newElement : cur)
        .toList();
  }

  // ── Delete ───────────────────────────────────────────────────────

  Future<void> deleteElement(T element) async {
    await _database!.delete(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [element.primaryKeyValue],
    );
    state = state
        .where((cur) => cur.primaryKeyValue != element.primaryKeyValue)
        .toList();
  }

  Future<void> clearTable() async {
    await _database!.delete(tableName);
    state = [];
  }

  Future<void> clearProvider() async {
    state = [];
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Future<bool> _elementExists(T element) async {
    final result = await _database!.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [element.primaryKeyValue],
    );
    return result.isNotEmpty;
  }

  /// Raw query helper for custom queries in subclasses.
  @protected
  Future<List<T>> queryWhere({
    required String where,
    required List<Object?> whereArgs,
    String? orderBy,
  }) async {
    final records = await _database!.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return records.map((r) => fromMap(r)).toList();
  }

  /// Raw query helper for aggregate queries.
  @protected
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return _database!.rawQuery(sql, arguments);
  }
}
