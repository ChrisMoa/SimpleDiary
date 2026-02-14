import 'dart:convert';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordAuthService', () {
    group('generateSalt', () {
      test('produces a 32-byte salt', () {
        final salt = PasswordAuthService.generateSalt();
        expect(salt.length, 32);
      });

      test('produces different salts on each call', () {
        final salt1 = PasswordAuthService.generateSalt();
        final salt2 = PasswordAuthService.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });
    });

    group('hashPassword', () {
      test('produces valid hash and salt as base64 strings', () {
        final result = PasswordAuthService.hashPassword('testPassword123');

        expect(result, contains('hashedPassword'));
        expect(result, contains('salt'));
        expect(result['hashedPassword'], isNotEmpty);
        expect(result['salt'], isNotEmpty);

        // Verify both are valid base64
        expect(() => base64.decode(result['hashedPassword']!), returnsNormally);
        expect(() => base64.decode(result['salt']!), returnsNormally);
      });

      test('hash has correct key length (32 bytes)', () {
        final result = PasswordAuthService.hashPassword('testPassword123');
        final hashBytes = base64.decode(result['hashedPassword']!);
        expect(hashBytes.length, 32);
      });

      test('different passwords produce different hashes', () {
        final result1 = PasswordAuthService.hashPassword('password1');
        final result2 = PasswordAuthService.hashPassword('password2');
        expect(result1['hashedPassword'], isNot(equals(result2['hashedPassword'])));
      });

      test('same password produces different hashes due to random salt', () {
        final result1 = PasswordAuthService.hashPassword('samePassword');
        final result2 = PasswordAuthService.hashPassword('samePassword');
        // Different salts mean different hashes
        expect(result1['salt'], isNot(equals(result2['salt'])));
        expect(result1['hashedPassword'], isNot(equals(result2['hashedPassword'])));
      });
    });

    group('verifyPassword', () {
      test('returns true for correct password', () {
        final result = PasswordAuthService.hashPassword('mySecurePassword');
        final isValid = PasswordAuthService.verifyPassword(
          'mySecurePassword',
          result['hashedPassword']!,
          result['salt']!,
        );
        expect(isValid, true);
      });

      test('returns false for wrong password', () {
        final result = PasswordAuthService.hashPassword('mySecurePassword');
        final isValid = PasswordAuthService.verifyPassword(
          'wrongPassword',
          result['hashedPassword']!,
          result['salt']!,
        );
        expect(isValid, false);
      });

      test('returns false for empty password when original was non-empty', () {
        final result = PasswordAuthService.hashPassword('mySecurePassword');
        final isValid = PasswordAuthService.verifyPassword(
          '',
          result['hashedPassword']!,
          result['salt']!,
        );
        expect(isValid, false);
      });

      test('works with special characters in password', () {
        const password = r'p@$$w0rd!#%^&*()_+-={}[]|:;<>?,./~`';
        final result = PasswordAuthService.hashPassword(password);
        final isValid = PasswordAuthService.verifyPassword(
          password,
          result['hashedPassword']!,
          result['salt']!,
        );
        expect(isValid, true);
      });

      test('works with unicode characters in password', () {
        const password = 'Passwort_mit_Ümläuten_und_ß';
        final result = PasswordAuthService.hashPassword(password);
        final isValid = PasswordAuthService.verifyPassword(
          password,
          result['hashedPassword']!,
          result['salt']!,
        );
        expect(isValid, true);
      });
    });

    group('getDatabaseEncryptionKey', () {
      test('produces consistent key for same password and salt', () {
        final result = PasswordAuthService.hashPassword('testPassword');
        final key1 = PasswordAuthService.getDatabaseEncryptionKey(
          'testPassword',
          result['salt']!,
        );
        final key2 = PasswordAuthService.getDatabaseEncryptionKey(
          'testPassword',
          result['salt']!,
        );
        expect(key1, equals(key2));
      });

      test('produces different key than password hash', () {
        final result = PasswordAuthService.hashPassword('testPassword');
        final encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(
          'testPassword',
          result['salt']!,
        );
        expect(encryptionKey, isNot(equals(result['hashedPassword'])));
      });

      test('produces valid base64 key', () {
        final result = PasswordAuthService.hashPassword('testPassword');
        final key = PasswordAuthService.getDatabaseEncryptionKey(
          'testPassword',
          result['salt']!,
        );
        expect(() => base64.decode(key), returnsNormally);
        final keyBytes = base64.decode(key);
        expect(keyBytes.length, 32);
      });

      test('different passwords produce different encryption keys', () {
        final result1 = PasswordAuthService.hashPassword('password1');
        final result2 = PasswordAuthService.hashPassword('password2');
        final key1 = PasswordAuthService.getDatabaseEncryptionKey(
          'password1',
          result1['salt']!,
        );
        final key2 = PasswordAuthService.getDatabaseEncryptionKey(
          'password2',
          result2['salt']!,
        );
        expect(key1, isNot(equals(key2)));
      });
    });
  });
}
