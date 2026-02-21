/// Clean base class for all persisted entities.
///
/// Subclasses must:
/// 1. Implement [toDbMap] for serialization
/// 2. Implement [primaryKeyValue] getter
/// 3. Provide a static `fromDbMap(Map<String, dynamic>)` factory
abstract class DbEntity {
  /// Serializes this entity to a map suitable for SQLite insertion.
  Map<String, dynamic> toDbMap();

  /// The value of this entity's primary key.
  dynamic get primaryKeyValue;
}
