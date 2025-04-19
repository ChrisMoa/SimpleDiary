// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';

class UserData implements LocalDbElement {
  String username;
  String password; // Hashed password
  String salt; // Salt for password hashing
  String email;
  String? userId;
  bool isLoggedIn;
  String _clearPassword; // Transient field, not stored

  UserData({
    username,
    password,
    salt,
    email,
    userId,
    isLoggedIn,
    String? clearPassword,
  })  : username = username ?? '',
        password = password ?? '',
        salt = salt ?? '',
        email = email ?? '',
        userId = userId ?? Utils.uuid.v4(),
        isLoggedIn = isLoggedIn ?? false,
        _clearPassword = clearPassword ?? '';

  // Getter and setter for clearPassword
  String get clearPassword => _clearPassword;
  set clearPassword(String value) => _clearPassword = value;

  factory UserData.fromEmpty() {
    return UserData();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'password': password,
      'salt': salt,
      'email': email,
      'userId': userId ?? Utils.uuid.v4(),
      // clearPassword is not stored in the map
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      username: map['username'] as String,
      password: map['password'] as String,
      salt: map['salt'] as String? ??
          '', // Handle null for backward compatibility
      email: map['email'] as String,
      userId: map['userId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    return UserData.fromMap(map);
  }

  @override
  getId() {
    return username;
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement map) {
    assert(map is UserData, '${map.getId()} has no type "UserData"');
    return (map as UserData).toMap();
  }
}
