import 'package:day_tracker/core/database/local_db_element.dart';

/// Clean base class replacing [LocalDbElement].
///
/// Key improvements over [LocalDbElement]:
/// - [toDbMap] has no redundant self-parameter
/// - [primaryKeyValue] getter instead of untyped `getId()`
/// - Deserialization moved to a static factory function (`fromDbMap`) —
///   single source of truth instead of duplicated instance methods
///
/// Implements [LocalDbElement] as a bridge so migrated entities still work
/// with code that hasn't been migrated yet (e.g. BackupService).
///
/// Subclasses must:
/// 1. Implement [toDbMap] for serialization
/// 2. Implement [primaryKeyValue] getter
/// 3. Provide a static `fromDbMap(Map<String, dynamic>)` factory
/// 4. Override [fromLocalDbMap] to delegate to that factory (one-liner
///    for backward compat with callers that still use the old API)
abstract class DbEntity implements LocalDbElement {
  /// Serializes this entity to a map suitable for SQLite insertion.
  Map<String, dynamic> toDbMap();

  /// The value of this entity's primary key.
  dynamic get primaryKeyValue;

  // ── LocalDbElement bridge ──────────────────────────────────────────

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) => toDbMap();

  @override
  dynamic getId() => primaryKeyValue;
}
