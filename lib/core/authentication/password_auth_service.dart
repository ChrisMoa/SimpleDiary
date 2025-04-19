import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class PasswordAuthService {
  // Constants for password hashing
  static const int _saltLength = 32;
  static const int _iterations = 10000;
  static const int _keyLength = 32; // 256 bits

  // Generate a random salt for password hashing
  static Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(_saltLength, (_) => random.nextInt(256)));
  }

  // Hash password using PBKDF2 with random salt
  static Map<String, String> hashPassword(String password) {
    final salt = generateSalt();
    final derivedKey = _deriveKeyFromPassword(password, salt);

    return {
      'hashedPassword': base64.encode(derivedKey),
      'salt': base64.encode(salt),
    };
  }

  // Verify a password against stored hash and salt
  static bool verifyPassword(
      String password, String hashedPassword, String salt) {
    final saltBytes = base64.decode(salt);
    final derivedKey = _deriveKeyFromPassword(password, saltBytes);

    return base64.encode(derivedKey) == hashedPassword;
  }

  // Generate a database encryption key from password and salt
  // This creates a key that is different from the password hash
  static String getDatabaseEncryptionKey(String password, String salt) {
    final saltBytes = base64.decode(salt);
    // Use a different derivation context for the encryption key
    final context = utf8.encode('db_encryption_key');
    final combinedInput = Uint8List.fromList([...saltBytes, ...context]);

    final keyBytes = _deriveKeyFromPassword(password, combinedInput,
        iterations: _iterations * 2);
    return base64.encode(keyBytes);
  }

  // PBKDF2 key derivation using SHA-256
  static Uint8List _deriveKeyFromPassword(String password, Uint8List salt,
      {int iterations = _iterations}) {
    final pbkdf2Params = Pbkdf2Parameters(salt, iterations, _keyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(pbkdf2Params);

    return pbkdf2.process(utf8.encode(password));
  }
}
