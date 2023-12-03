import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettings {
  static AppSettings? _instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String username = '';
  String email = '';
  String password = '';

  var accessToken = '';

  void _readValues() async {
    username = await _storage.read(key: 'username') ?? '';
    email = await _storage.read(key: 'email') ?? '';
    password = await _storage.read(key: 'password') ?? '';
  }

  void writeSettingsToPreferences() async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  void resetCredentials() async {
    username = '';
    email = '';
    password = '';
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  AppSettings._() {
    _readValues();
  }

  // Factory constructor to create or return the instance
  factory AppSettings() {
    _instance ??= AppSettings._();
    return _instance!;
  }
}
