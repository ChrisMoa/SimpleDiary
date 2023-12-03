abstract class RemoteDbElement {
  Map<String, dynamic> toRemoteDbMap();

  RemoteDbElement fromRemoteDbMap(Map<String, dynamic> map);

  dynamic getId();
}
