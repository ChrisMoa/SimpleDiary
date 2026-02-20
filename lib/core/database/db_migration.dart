import 'package:sqflite/sqflite.dart';

/// Declarative, version-ordered migration for a single entity table.
///
/// Migrations are applied in [version] order. Each migration runs
/// idempotently — adding a column that already exists is silently ignored.
class DbMigration {
  final int version;
  final String description;
  final Future<void> Function(Database db, String tableName) execute;

  const DbMigration({
    required this.version,
    required this.description,
    required this.execute,
  });

  /// Convenience: add a column if it doesn't already exist.
  DbMigration.addColumn({
    required this.version,
    required String columnName,
    required String columnDefinition,
    this.description = '',
  }) : execute = _addColumnExecutor(columnName, columnDefinition);

  /// Convenience: create an index if it doesn't already exist.
  DbMigration.addIndex({
    required this.version,
    required String indexName,
    required String indexSql,
    this.description = '',
  }) : execute = _addIndexExecutor(indexName, indexSql);

  static Future<void> Function(Database, String) _addColumnExecutor(
    String columnName,
    String columnDefinition,
  ) {
    return (Database db, String tableName) async {
      try {
        await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
        );
      } catch (_) {
        // Column already exists — expected on subsequent runs.
      }
    };
  }

  static Future<void> Function(Database, String) _addIndexExecutor(
    String indexName,
    String indexSql,
  ) {
    return (Database db, String tableName) async {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS $indexName ON $tableName ($indexSql)',
      );
    };
  }
}
