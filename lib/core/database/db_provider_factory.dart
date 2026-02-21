import 'package:day_tracker/core/database/db_column.dart';
import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_migration.dart';
import 'package:day_tracker/core/database/db_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates a fully wired Riverpod [StateNotifierProvider] for [DbRepository].
///
/// This is the one-line factory that replaces the boilerplate triple of
/// Model + LocalDbHelper subclass + AbstractLocalDbProviderState subclass.
///
/// Example:
/// ```dart
/// final habitEntriesProvider = createDbProvider<HabitEntry>(
///   tableName: 'habit_entries',
///   columns: HabitEntry.columns,
///   fromMap: HabitEntry.fromDbMap,
///   migrations: HabitEntry.migrations,
/// );
/// ```
StateNotifierProvider<DbRepository<T>, List<T>>
    createDbProvider<T extends DbEntity>({
  required String tableName,
  required List<DbColumn> columns,
  required T Function(Map<String, dynamic>) fromMap,
  List<DbMigration> migrations = const [],
  List<String> additionalSql = const [],
}) {
  return StateNotifierProvider<DbRepository<T>, List<T>>((ref) {
    return DbRepository<T>(
      tableName: tableName,
      columns: columns,
      fromMap: fromMap,
      migrations: migrations,
      additionalSql: additionalSql,
    );
  });
}
