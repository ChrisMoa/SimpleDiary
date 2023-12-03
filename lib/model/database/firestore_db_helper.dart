import 'dart:convert';

import 'package:SimpleDiary/model/database/remote_db_element.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:http/http.dart' as http;

class FirestoreDbHelper {
  final String projectId;
  final String collectionName;
  final String webApiKey;

  String _idToken = '';

  FirestoreDbHelper({required this.projectId, required this.collectionName, required this.webApiKey});

  set idToken(String token) {
    _idToken = token;
  }

  Future<void> insert(RemoteDbElement remoteDbElement) async {
    final firebaseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/${remoteDbElement.getId()}';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_idToken',
    };
    final body = jsonEncode(remoteDbElement.toRemoteDbMap());

    final response = await http.patch(
      Uri.parse(firebaseUrl),
      body: body,
      headers: headers,
    );

    assert(response.statusCode == 200, 'Failed to write element to $collectionName. Status code: ${response.statusCode}');
  }

  Future<int> queryRowCount() async {
    return (await getAllRecordsAsObjects()).length;
  }

  Future<void> update(RemoteDbElement remoteDbElement) async {
    final firebaseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/${remoteDbElement.getId()}';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_idToken',
    };
    final body = jsonEncode(remoteDbElement.toRemoteDbMap());

    final response = await http.patch(
      Uri.parse(firebaseUrl),
      body: body,
      headers: headers,
    );

    assert(response.statusCode == 200, 'Failed to update element to $collectionName. Status code: ${response.statusCode}');
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<void> delete(RemoteDbElement remoteDiaryElement) async {
    final firebaseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/${remoteDiaryElement.getId()}';

    final headers = {
      'Authorization': 'Bearer $_idToken',
    };

    final response = await http.delete(Uri.parse(firebaseUrl), headers: headers);

    assert(response.statusCode == 200, 'Failed to delete element to $collectionName. Status code: ${response.statusCode}');
  }

  Future<List<RemoteDbElement>> getAllRecordsAsObjects() async {
    String? nextPageToken;
    List<RemoteDbElement> remoteDbElements = [];

    do {
      // Make a request to Firestore with or without nextPageToken
      String url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName' + (nextPageToken != null ? '?pageToken=$nextPageToken&' : '?') + 'key=$webApiKey';
      LogWrapper.logger.t('url: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_idToken'},
      );
      assert(response.statusCode == 200, 'Failed to read all elements at $collectionName. Status code: ${response.statusCode}');
      LogWrapper.logger.t(response.body.toString());
      final Map<String, dynamic> data = json.decode(response.body);
      assert(data.containsKey('documents'), 'data has note key "documents". data: ${data.toString()}');

      //* create database objects
      final List<dynamic> documents = data['documents'];
      for (var document in documents) {
        try {
          final Map<String, dynamic> fields = document['fields'];
          LogWrapper.logger.t(fields.toString());
          remoteDbElements.add(generateElementFromDbMap(fields));
        } catch (e) {
          LogWrapper.logger.w('found invalid item in collection $collectionName: ${document['name']}');
        }
      }

      final nextPageTokenJson = data['nextPageToken'];
      nextPageToken = nextPageTokenJson?.toString();
    } while (nextPageToken != null);
    return remoteDbElements;
  }

  // generates a local db element from the given map (localDbElement can be e.g. a note)
  // this function exists because a direct conversion to the right class is not possible
  RemoteDbElement generateElementFromDbMap(Map<String, dynamic> elementMap) {
    throw UnimplementedError();
  }
}
