import 'package:SimpleDiary/model/database/firestore_db_helper.dart';
import 'package:SimpleDiary/model/database/remote_db_element.dart';
import 'package:SimpleDiary/model/notes/note.dart';

class NotesFirestoreAPI extends FirestoreDbHelper {
  NotesFirestoreAPI(
      {required super.projectId,
      required super.collectionName,
      required super.webApiKey});

  @override
  RemoteDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    return Note.fromEmpty().fromRemoteDbMap(elementMap);
  }
}
