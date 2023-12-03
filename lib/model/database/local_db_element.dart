abstract class LocalDbElement {
  Map<String, dynamic> toLocalDbMap(LocalDbElement map);

  LocalDbElement fromLocalDbMap(Map<String, dynamic> map);

  dynamic getId();
}
