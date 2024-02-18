/// this is only an abstract class for the sub settings

abstract class Settings {
  
  /// @brief converts the settings class to a map
  /// @return the class converted to map 
  Future<Map<String, dynamic>> toMap();

  /// @brief overwrites the class parameters read from the map 
  /// @map the map filled with the settings parameter
  Future<void> fromMap(Map<String, dynamic> map);

  String get name;
}