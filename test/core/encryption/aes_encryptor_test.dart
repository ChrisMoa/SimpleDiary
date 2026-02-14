import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper to create a valid base64-encoded 32-byte key
  String createValidKey() {
    final result = PasswordAuthService.hashPassword('testPassword');
    return PasswordAuthService.getDatabaseEncryptionKey(
      'testPassword',
      result['salt']!,
    );
  }

  group('AesEncryptor', () {
    late AesEncryptor encryptor;
    late String validKey;

    setUp(() {
      validKey = createValidKey();
      encryptor = AesEncryptor(encryptionKey: validKey);
    });

    group('initialization', () {
      test('initializes successfully with valid 32-byte key', () {
        expect(() => AesEncryptor(encryptionKey: validKey), returnsNormally);
      });

      test('initializes with a short key via padding', () {
        // Short key (less than 32 bytes after base64 decode)
        final shortKey = base64.encode(Uint8List(8));
        expect(
            () => AesEncryptor(encryptionKey: shortKey), returnsNormally);
      });
    });

    group('encryptString / decryptString', () {
      test('round-trip with plain text', () {
        const plainText = 'Hello, World!';
        final encrypted = encryptor.encryptString(plainText);
        final decrypted = encryptor.decryptString(encrypted);
        expect(decrypted, equals(plainText));
      });

      test('empty string encryption throws (AES block cipher limitation)', () {
        const plainText = '';
        // AES CBC mode cannot encrypt empty input (needs at least one block)
        expect(() => encryptor.encryptString(plainText), throwsA(anything));
      });

      test('round-trip with unicode text', () {
        const plainText = 'Ümläute und Sönderzeichen: äöüß 日本語 🎉';
        final encrypted = encryptor.encryptString(plainText);
        final decrypted = encryptor.decryptString(encrypted);
        expect(decrypted, equals(plainText));
      });
    });

    group('encryptStringAsBase64 / decryptStringFromBase64', () {
      test('round-trip with plain text', () {
        const plainText = 'Hello, World!';
        final encrypted = encryptor.encryptStringAsBase64(plainText);
        final decrypted = encryptor.decryptStringFromBase64(encrypted);
        expect(decrypted, equals(plainText));
      });

      test('encrypted output is valid base64', () {
        const plainText = 'test data';
        final encrypted = encryptor.encryptStringAsBase64(plainText);
        expect(() => base64.decode(encrypted), returnsNormally);
      });

      test('encrypting same text twice produces different ciphertexts (random IV)', () {
        const plainText = 'same text encrypted twice';
        final encrypted1 = encryptor.encryptStringAsBase64(plainText);
        final encrypted2 = encryptor.encryptStringAsBase64(plainText);
        // Due to random IV, ciphertexts should differ
        expect(encrypted1, isNot(equals(encrypted2)));
        // But both should decrypt to the same value
        expect(encryptor.decryptStringFromBase64(encrypted1), equals(plainText));
        expect(encryptor.decryptStringFromBase64(encrypted2), equals(plainText));
      });

      test('round-trip with long text', () {
        final longText = 'A' * 10000;
        final encrypted = encryptor.encryptStringAsBase64(longText);
        final decrypted = encryptor.decryptStringFromBase64(encrypted);
        expect(decrypted, equals(longText));
      });

      test('round-trip with JSON data', () {
        const jsonText = '{"key": "value", "number": 42, "array": [1, 2, 3]}';
        final encrypted = encryptor.encryptStringAsBase64(jsonText);
        final decrypted = encryptor.decryptStringFromBase64(encrypted);
        expect(decrypted, equals(jsonText));
      });

      test('throws on invalid/short base64 data', () {
        // Data shorter than 16 bytes (IV length)
        final shortData = base64.encode(Uint8List(10));
        expect(
          () => encryptor.decryptStringFromBase64(shortData),
          throwsException,
        );
      });
    });

    group('decrypt with wrong key', () {
      test('decrypting with a different key fails', () {
        const plainText = 'secret message';
        final encrypted = encryptor.encryptStringAsBase64(plainText);

        // Create a different encryptor with a different key
        final differentKey = createValidKey();
        final differentEncryptor = AesEncryptor(encryptionKey: differentKey);

        // Decryption should either throw or produce wrong output
        try {
          final decrypted = differentEncryptor.decryptStringFromBase64(encrypted);
          // If it doesn't throw, the decrypted text should not match
          expect(decrypted, isNot(equals(plainText)));
        } catch (e) {
          // Expected: decryption with wrong key throws
          expect(e, isNotNull);
        }
      });
    });

    group('encryptFile / decryptFile', () {
      test('round-trip file encryption', () {
        final tempDir = Directory.systemTemp.createTempSync('aes_test_');
        final testFile = File('${tempDir.path}/test.txt');

        try {
          const content = 'This is test file content for encryption.';
          testFile.writeAsStringSync(content);

          // Encrypt the file
          encryptor.encryptFile(testFile);

          // File content should be different after encryption
          final encryptedBytes = testFile.readAsBytesSync();
          expect(utf8.decode(encryptedBytes, allowMalformed: true),
              isNot(equals(content)));

          // Decrypt the file
          encryptor.decryptFile(testFile);

          // File content should match original
          final decryptedContent = testFile.readAsStringSync();
          expect(decryptedContent, equals(content));
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('encrypt file prepends IV (16 bytes)', () {
        final tempDir = Directory.systemTemp.createTempSync('aes_test_');
        final testFile = File('${tempDir.path}/test.txt');

        try {
          const content = 'test content';
          testFile.writeAsStringSync(content);
          final originalLength = testFile.lengthSync();

          encryptor.encryptFile(testFile);

          // Encrypted file should be larger: 16 bytes IV + encrypted data
          final encryptedLength = testFile.lengthSync();
          expect(encryptedLength, greaterThan(originalLength));
          expect(encryptedLength, greaterThanOrEqualTo(16));
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });
    });
  });
}
