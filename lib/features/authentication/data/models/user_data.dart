// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/utils/utils.dart';

final testUserData = UserData(
    username: 'Test',
    pin: '1234',
    email: 'test@gmail.de',
    password: '123456789',
    userId: 'test');

class UserData implements LocalDbElement {
  String username;
  String pin;
  String email = '';
  String password = '';
  String? userId;
  bool isLoggedIn = false;

  UserData({
    username,
    pin,
    email,
    password,
    userId,
  })  : username = username ?? '',
        pin = pin ?? '',
        email = email ?? '',
        password = password ?? '',
        userId = userId ?? Utils.uuid.v4();

  factory UserData.fromEmpty() {
    return UserData();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'pin': pin,
      'email': email,
      'password': password,
      'userId': userId ?? Utils.uuid.v4(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      username: map['username'] as String,
      pin: map['pin'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
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
