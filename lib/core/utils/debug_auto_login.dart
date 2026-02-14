import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DebugAutoLogin {
  static bool get isEnabled =>
      kDebugMode && dotenv.env['DEBUG_AUTO_LOGIN'] == 'true';

  static String get username => dotenv.env['DEBUG_USERNAME'] ?? '';
  static String get password => dotenv.env['DEBUG_PASSWORD'] ?? '';
  static String get email => dotenv.env['DEBUG_EMAIL'] ?? '';

  static bool get hasValidCredentials =>
      username.isNotEmpty && password.length >= 8;
}
