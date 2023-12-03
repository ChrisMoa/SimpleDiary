import 'package:http/http.dart' as http;
import 'dart:convert';

class FirestoreAPI {
  // Method to perform email and password authentication with Firebase
  static Future<String> signInWithEmailPassword(
      {required String apiKey,
      required String email,
      required String password}) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey");

    final response = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );

    final responseData = json.decode(response.body);

    if (responseData.containsKey("idToken")) {
      return responseData["idToken"];
    }
    return '';
  }

  static Future<bool> isCredentialValid(
      {required String apiKey,
      required String email,
      required String password}) async {
    final token = await signInWithEmailPassword(
        apiKey: apiKey, email: email, password: password);
    return token.isNotEmpty;
  }
}
