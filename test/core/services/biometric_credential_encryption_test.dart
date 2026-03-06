import 'dart:convert';

import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the app-level encryption layer used by BiometricService.
/// We test the encryption logic in isolation since FlutterSecureStorage
/// and LocalAuthentication require platform-specific setup.
void main() {
  group('Biometric credential encryption', () {
    late AesEncryptor encryptor;

    setUp(() {
      // Same key used in BiometricService._credentialEncryptor
      encryptor = AesEncryptor(
        encryptionKey: base64.encode(
          utf8.encode('day_tracker_biometric_credential_k!'),
        ),
      );
    });

    test('encrypt/decrypt round-trip preserves password', () {
      const password = 'MySecureP@ss123';
      final encrypted = encryptor.encryptStringAsBase64(password);
      final decrypted = encryptor.decryptStringFromBase64(encrypted);
      expect(decrypted, equals(password));
    });

    test('encrypted output differs from plaintext', () {
      const password = 'TestPassword!';
      final encrypted = encryptor.encryptStringAsBase64(password);
      expect(encrypted, isNot(equals(password)));
    });

    test('different passwords produce different encrypted outputs', () {
      final enc1 = encryptor.encryptStringAsBase64('password1abc');
      final enc2 = encryptor.encryptStringAsBase64('password2xyz');
      expect(enc1, isNot(equals(enc2)));
    });

    test('same password produces different encrypted outputs (random IV)', () {
      const password = 'SamePassword123';
      final enc1 = encryptor.encryptStringAsBase64(password);
      final enc2 = encryptor.encryptStringAsBase64(password);
      expect(enc1, isNot(equals(enc2)));
    });

    test('handles special characters in password', () {
      const password = 'P@\$\$w0rd!#%^&*()_+-=[]{}|;:,.<>?/~`';
      final encrypted = encryptor.encryptStringAsBase64(password);
      final decrypted = encryptor.decryptStringFromBase64(encrypted);
      expect(decrypted, equals(password));
    });

    test('handles unicode in password', () {
      const password = 'Pässwörd123!日本語';
      final encrypted = encryptor.encryptStringAsBase64(password);
      final decrypted = encryptor.decryptStringFromBase64(encrypted);
      expect(decrypted, equals(password));
    });

    test('backward compat: plaintext fails decryption gracefully', () {
      // Simulates what happens when getStoredPassword reads a legacy
      // plaintext value — the decryption should throw, allowing fallback
      const legacyPlaintext = 'OldPlainPassword';
      expect(
        () => encryptor.decryptStringFromBase64(legacyPlaintext),
        throwsA(anything),
      );
    });
  });
}
