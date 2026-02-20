import 'package:day_tracker/core/database/db_column.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DbColumn', () {
    group('toSqlDefinition', () {
      test('text primary key', () {
        const col = DbColumn.textPrimaryKey('id');
        expect(col.toSqlDefinition(), 'id TEXT PRIMARY KEY');
      });

      test('text not null', () {
        const col = DbColumn.text('name');
        expect(col.toSqlDefinition(), 'name TEXT NOT NULL');
      });

      test('text nullable', () {
        const col = DbColumn.text('bio', isNotNull: false);
        expect(col.toSqlDefinition(), 'bio TEXT');
      });

      test('text with default', () {
        const col = DbColumn.text('status', defaultValue: "''");
        expect(col.toSqlDefinition(), "status TEXT NOT NULL DEFAULT ''");
      });

      test('integer not null', () {
        const col = DbColumn.integer('count');
        expect(col.toSqlDefinition(), 'count INTEGER NOT NULL');
      });

      test('integer with default', () {
        const col = DbColumn.integer('score', defaultValue: '0');
        expect(col.toSqlDefinition(), 'score INTEGER NOT NULL DEFAULT 0');
      });

      test('real not null', () {
        const col = DbColumn.real('value');
        expect(col.toSqlDefinition(), 'value REAL NOT NULL');
      });

      test('custom column type', () {
        const col = DbColumn(
          name: 'data',
          sqlType: 'BLOB',
          isNotNull: true,
        );
        expect(col.toSqlDefinition(), 'data BLOB NOT NULL');
      });
    });

    group('createTableSql', () {
      test('generates valid CREATE TABLE statement', () {
        const columns = [
          DbColumn.textPrimaryKey('id'),
          DbColumn.text('name'),
          DbColumn.integer('age', defaultValue: '0'),
        ];

        final sql = DbColumn.createTableSql('users', columns);
        expect(
          sql,
          'CREATE TABLE IF NOT EXISTS users '
          '(id TEXT PRIMARY KEY, name TEXT NOT NULL, age INTEGER NOT NULL DEFAULT 0)',
        );
      });

      test('single column table', () {
        const columns = [DbColumn.textPrimaryKey('id')];
        final sql = DbColumn.createTableSql('simple', columns);
        expect(sql, 'CREATE TABLE IF NOT EXISTS simple (id TEXT PRIMARY KEY)');
      });
    });

    group('convenience constructors', () {
      test('textPrimaryKey sets isPrimaryKey', () {
        const col = DbColumn.textPrimaryKey('id');
        expect(col.isPrimaryKey, true);
        expect(col.sqlType, 'TEXT');
        expect(col.name, 'id');
      });

      test('text defaults to isNotNull true', () {
        const col = DbColumn.text('title');
        expect(col.isNotNull, true);
        expect(col.isPrimaryKey, false);
      });

      test('integer defaults to isNotNull true', () {
        const col = DbColumn.integer('count');
        expect(col.isNotNull, true);
      });

      test('real defaults to isNotNull true', () {
        const col = DbColumn.real('value');
        expect(col.isNotNull, true);
      });
    });
  });
}
