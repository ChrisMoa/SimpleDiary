// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';

class UserData {
  String username;
  String password; // Hashed password
  String salt; // Salt for password hashing
  String email;
  String? userId;
  bool isLoggedIn;
  String _sessionEncryptionKey; // Derived encryption key, transient, not stored
  String _initialPassword; // Raw password, only for createUser/updateUser, never persisted

  UserData({
    username,
    password,
    salt,
    email,
    userId,
    isLoggedIn,
    String? clearPassword,
    String? sessionEncryptionKey,
  })  : username = username ?? '',
        password = password ?? '',
        salt = salt ?? '',
        email = email ?? '',
        userId = userId ?? Utils.uuid.v4(),
        isLoggedIn = isLoggedIn ?? false,
        _sessionEncryptionKey = sessionEncryptionKey ?? '',
        _initialPassword = clearPassword ?? '';

  /// Derived encryption key for the current session. Not persisted.
  String get sessionEncryptionKey => _sessionEncryptionKey;
  set sessionEncryptionKey(String value) => _sessionEncryptionKey = value;

  /// The raw password passed via constructor, used only by createUser/updateUser.
  /// Not persisted, not stored in memory after key derivation.
  String get initialPassword => _initialPassword;

  /// Deprecated: Raw password is no longer stored in memory after login.
  /// Use [sessionEncryptionKey] for encryption operations.
  @Deprecated('Use sessionEncryptionKey instead')
  String get clearPassword => '';

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
      // sessionEncryptionKey is transient and not stored in the map
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
}
