import 'dart:convert';
import 'dart:typed_data';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Security hardening', () {
    group('AES random IV (issue #161)', () {
      late AesEncryptor encryptor;

      setUp(() {
        final result = PasswordAuthService.hashPassword('testPassword');
        final key = PasswordAuthService.getDatabaseEncryptionKey(
          'testPassword',
          result['salt']!,
        );
        encryptor = AesEncryptor(encryptionKey: key);
      });

      test('encryptString produces different output for same input', () {
        const plainText = 'same text';
        final enc1 = encryptor.encryptString(plainText);
        final enc2 = encryptor.encryptString(plainText);
        // Due to random IV, outputs should differ
        expect(base64.encode(enc1), isNot(equals(base64.encode(enc2))));
      });

      test('encryptString/decryptString round-trip works with random IV', () {
        const plainText = 'Hello, secure world!';
        final encrypted = encryptor.encryptString(plainText);
        final decrypted = encryptor.decryptString(encrypted);
        expect(decrypted, equals(plainText));
      });

      test('decryptString rejects data shorter than IV (16 bytes)', () {
        final shortData = Uint8List(10);
        expect(
          () => encryptor.decryptString(shortData),
          throwsException,
        );
      });
    });

    group('URL protocol support (issue #170)', () {
      test('SupabaseSettings.isConfigured accepts both HTTP and HTTPS URLs', () {
        final httpSettings = SupabaseSettings(
          supabaseUrl: 'http://localhost:8000',
          supabaseAnonKey: 'key',
          email: 'user@test.com',
          password: 'pass',
        );
        expect(httpSettings.isConfigured, true);

        final httpsSettings = SupabaseSettings(
          supabaseUrl: 'https://secure.example.com',
          supabaseAnonKey: 'key',
          email: 'user@test.com',
          password: 'pass',
        );
        expect(httpsSettings.isConfigured, true);
      });

      test('SupabaseSettings.isHttpUrl detects insecure HTTP URLs', () {
        final settings = SupabaseSettings(
          supabaseUrl: 'http://localhost:8000',
          supabaseAnonKey: 'key',
          email: 'user@test.com',
          password: 'pass',
        );
        expect(settings.isHttpUrl, true);
      });
    });

    group('Credential encryption at rest (issue #153)', () {
      test('Supabase email is encrypted in serialized map', () {
        final settings = SupabaseSettings(
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'anon-key',
          email: 'secret@email.com',
          password: 'secretPassword',
        );
        final map = settings.toMap();

        expect(map['email'], isNot(equals('secret@email.com')));
        expect(map['password'], isNot(equals('secretPassword')));
        expect(map['credentials_encrypted'], true);
      });

      test('Supabase credentials survive round-trip', () {
        final original = SupabaseSettings(
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'anon-key',
          email: 'test@example.com',
          password: 'MySecretP@ss1',
        );

        final map = original.toMap();
        final restored = SupabaseSettings.fromMap(map);

        expect(restored.email, equals(original.email));
        expect(restored.password, equals(original.password));
        expect(restored.supabaseUrl, equals(original.supabaseUrl));
      });

      test('backward compatibility with unencrypted settings', () {
        final legacyMap = {
          'supabase_url': 'https://old.supabase.co',
          'supabase_anon_key': 'old-key',
          'email': 'old@example.com',
          'password': 'oldPassword',
          // No credentials_encrypted flag
        };

        final settings = SupabaseSettings.fromMap(legacyMap);
        expect(settings.email, equals('old@example.com'));
        expect(settings.password, equals('oldPassword'));
      });

      test('empty credentials are not encrypted', () {
        final settings = SupabaseSettings.empty();
        final map = settings.toMap();
        expect(map['email'], equals(''));
        expect(map['password'], equals(''));
      });
    });
  });
}
