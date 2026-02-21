/// Declarative column definition for database tables.
///
/// Used by [DbRepository] to auto-generate CREATE TABLE SQL and
/// to provide a single source of truth for the schema.
class DbColumn {
  final String name;
  final String sqlType;
  final bool isPrimaryKey;
  final bool isNotNull;
  final String? defaultValue;

  const DbColumn({
    required this.name,
    required this.sqlType,
    this.isPrimaryKey = false,
    this.isNotNull = false,
    this.defaultValue,
  });

  /// Convenience constructors for common column types.

  const DbColumn.textPrimaryKey(this.name)
      : sqlType = 'TEXT',
        isPrimaryKey = true,
        isNotNull = false,
        defaultValue = null;

  const DbColumn.text(this.name, {this.isNotNull = true, this.defaultValue})
      : sqlType = 'TEXT',
        isPrimaryKey = false;

  const DbColumn.integer(this.name, {this.isNotNull = true, this.defaultValue})
      : sqlType = 'INTEGER',
        isPrimaryKey = false;

  const DbColumn.real(this.name, {this.isNotNull = true, this.defaultValue})
      : sqlType = 'REAL',
        isPrimaryKey = false;

  /// Generates the SQL fragment for this column in a CREATE TABLE statement.
  String toSqlDefinition() {
    final parts = <String>[name, sqlType];
    if (isPrimaryKey) parts.add('PRIMARY KEY');
    if (isNotNull && !isPrimaryKey) parts.add('NOT NULL');
    if (defaultValue != null) parts.add('DEFAULT $defaultValue');
    return parts.join(' ');
  }

  /// Generates a CREATE TABLE statement from a list of columns.
  static String createTableSql(String tableName, List<DbColumn> columns) {
    final columnDefs = columns.map((c) => c.toSqlDefinition()).join(', ');
    return 'CREATE TABLE IF NOT EXISTS $tableName ($columnDefs)';
  }
}
