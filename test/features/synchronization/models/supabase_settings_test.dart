import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseSettings', () {
    SupabaseSettings createSampleSettings() {
      return SupabaseSettings(
        supabaseUrl: 'https://localhost:8000',
        supabaseAnonKey: 'test-anon-key-123',
        email: 'user@example.com',
        password: 'testPassword',
      );
    }

    SupabaseSettings createFullSettings() {
      return SupabaseSettings(
        supabaseUrl: 'https://localhost:8000',
        supabaseAnonKey: 'test-anon-key-123',
        email: 'user@example.com',
        password: 'testPassword',
        autoSyncEnabled: true,
        autoSyncDebounceSeconds: 60,
        lastAutoSyncTimestamp: '2026-03-04T10:30:00.000Z',
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final settings = createSampleSettings();
        expect(settings.supabaseUrl, 'https://localhost:8000');
        expect(settings.supabaseAnonKey, 'test-anon-key-123');
        expect(settings.email, 'user@example.com');
        expect(settings.password, 'testPassword');
      });

      test('empty creates all empty strings', () {
        final settings = SupabaseSettings.empty();
        expect(settings.supabaseUrl, '');
        expect(settings.supabaseAnonKey, '');
        expect(settings.email, '');
        expect(settings.password, '');
      });

      test('auto-sync fields default correctly', () {
        final settings = createSampleSettings();
        expect(settings.autoSyncEnabled, false);
        expect(settings.autoSyncDebounceSeconds, 30);
        expect(settings.lastAutoSyncTimestamp, isNull);
      });

      test('empty factory defaults auto-sync fields', () {
        final settings = SupabaseSettings.empty();
        expect(settings.autoSyncEnabled, false);
        expect(settings.autoSyncDebounceSeconds, 30);
        expect(settings.lastAutoSyncTimestamp, isNull);
      });

      test('creates with all fields including auto-sync', () {
        final settings = createFullSettings();
        expect(settings.autoSyncEnabled, true);
        expect(settings.autoSyncDebounceSeconds, 60);
        expect(settings.lastAutoSyncTimestamp, '2026-03-04T10:30:00.000Z');
      });
    });

    group('isConfigured', () {
      test('returns true when all connection fields are set', () {
        final settings = createSampleSettings();
        expect(settings.isConfigured, true);
      });

      test('returns false when URL is empty', () {
        final settings = createSampleSettings().copyWith(supabaseUrl: '');
        expect(settings.isConfigured, false);
      });

      test('returns false when anonKey is empty', () {
        final settings = createSampleSettings().copyWith(supabaseAnonKey: '');
        expect(settings.isConfigured, false);
      });

      test('returns false when email is empty', () {
        final settings = createSampleSettings().copyWith(email: '');
        expect(settings.isConfigured, false);
      });

      test('returns false when password is empty', () {
        final settings = createSampleSettings().copyWith(password: '');
        expect(settings.isConfigured, false);
      });

      test('returns false for empty settings', () {
        final settings = SupabaseSettings.empty();
        expect(settings.isConfigured, false);
      });
    });

    group('lastAutoSyncDateTime', () {
      test('returns null when timestamp is null', () {
        final settings = createSampleSettings();
        expect(settings.lastAutoSyncDateTime, isNull);
      });

      test('parses valid ISO timestamp', () {
        final settings = createFullSettings();
        final dateTime = settings.lastAutoSyncDateTime;
        expect(dateTime, isNotNull);
        expect(dateTime!.year, 2026);
        expect(dateTime.month, 3);
        expect(dateTime.day, 4);
      });

      test('returns null for invalid timestamp', () {
        final settings =
            createSampleSettings().copyWith(lastAutoSyncTimestamp: 'invalid');
        expect(settings.lastAutoSyncDateTime, isNull);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleSettings();
        final map = original.toMap();
        final restored = SupabaseSettings.fromMap(map);

        expect(restored.supabaseUrl, original.supabaseUrl);
        expect(restored.supabaseAnonKey, original.supabaseAnonKey);
        expect(restored.email, original.email);
        expect(restored.password, original.password);
      });

      test('round-trip preserves auto-sync fields', () {
        final original = createFullSettings();
        final map = original.toMap();
        final restored = SupabaseSettings.fromMap(map);

        expect(restored.autoSyncEnabled, original.autoSyncEnabled);
        expect(restored.autoSyncDebounceSeconds,
            original.autoSyncDebounceSeconds);
        expect(
            restored.lastAutoSyncTimestamp, original.lastAutoSyncTimestamp);
      });

      test('map uses snake_case keys', () {
        final settings = createFullSettings();
        final map = settings.toMap();

        expect(map, contains('supabase_url'));
        expect(map, contains('supabase_anon_key'));
        expect(map, contains('email'));
        expect(map, contains('password'));
        expect(map, contains('auto_sync_enabled'));
        expect(map, contains('auto_sync_debounce_seconds'));
        expect(map, contains('last_auto_sync_timestamp'));
      });

      test('fromMap handles missing keys with empty defaults', () {
        final settings = SupabaseSettings.fromMap({});
        expect(settings.supabaseUrl, '');
        expect(settings.supabaseAnonKey, '');
        expect(settings.email, '');
        expect(settings.password, '');
      });

      test('fromMap handles missing auto-sync keys with defaults', () {
        final settings = SupabaseSettings.fromMap({
          'supabase_url': 'http://test.com',
          'email': 'test@test.com',
        });
        expect(settings.autoSyncEnabled, false);
        expect(settings.autoSyncDebounceSeconds, 30);
        expect(settings.lastAutoSyncTimestamp, isNull);
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = createSampleSettings();
        final copy = original.copyWith(email: 'new@example.com');

        expect(copy.email, 'new@example.com');
        expect(copy.supabaseUrl, original.supabaseUrl);
        expect(copy.supabaseAnonKey, original.supabaseAnonKey);
        expect(copy.password, original.password);
      });

      test('can update all fields', () {
        final original = createSampleSettings();
        final copy = original.copyWith(
          supabaseUrl: 'http://new-url.com',
          supabaseAnonKey: 'new-key',
          email: 'new@test.com',
          password: 'newPass',
        );

        expect(copy.supabaseUrl, 'http://new-url.com');
        expect(copy.supabaseAnonKey, 'new-key');
        expect(copy.email, 'new@test.com');
        expect(copy.password, 'newPass');
      });

      test('can update auto-sync fields', () {
        final original = createSampleSettings();
        final copy = original.copyWith(
          autoSyncEnabled: true,
          autoSyncDebounceSeconds: 120,
          lastAutoSyncTimestamp: '2026-01-01T00:00:00Z',
        );

        expect(copy.autoSyncEnabled, true);
        expect(copy.autoSyncDebounceSeconds, 120);
        expect(copy.lastAutoSyncTimestamp, '2026-01-01T00:00:00Z');
        // Original connection fields preserved
        expect(copy.supabaseUrl, original.supabaseUrl);
        expect(copy.email, original.email);
      });

      test('no-args copyWith preserves all fields', () {
        final original = createFullSettings();
        final copy = original.copyWith();

        expect(copy.supabaseUrl, original.supabaseUrl);
        expect(copy.supabaseAnonKey, original.supabaseAnonKey);
        expect(copy.email, original.email);
        expect(copy.password, original.password);
        expect(copy.autoSyncEnabled, original.autoSyncEnabled);
        expect(copy.autoSyncDebounceSeconds,
            original.autoSyncDebounceSeconds);
        expect(
            copy.lastAutoSyncTimestamp, original.lastAutoSyncTimestamp);
      });
    });

    group('HTTPS validation', () {
      test('isConfigured returns false for HTTP URL', () {
        final settings = SupabaseSettings(
          supabaseUrl: 'http://insecure.example.com',
          supabaseAnonKey: 'key',
          email: 'user@test.com',
          password: 'pass',
        );
        expect(settings.isConfigured, false);
      });

      test('isConfigured returns true for HTTPS URL', () {
        final settings = createSampleSettings();
        expect(settings.isConfigured, true);
      });
    });

    group('credential encryption at rest', () {
      test('toMap encrypts email and password', () {
        final settings = createSampleSettings();
        final map = settings.toMap();

        // The stored values should NOT be plaintext
        expect(map['email'], isNot(equals('user@example.com')));
        expect(map['password'], isNot(equals('testPassword')));
        expect(map['credentials_encrypted'], true);
      });

      test('toMap does not encrypt URL or anonKey', () {
        final settings = createSampleSettings();
        final map = settings.toMap();

        expect(map['supabase_url'], equals('https://localhost:8000'));
        expect(map['supabase_anon_key'], equals('test-anon-key-123'));
      });

      test('fromMap decrypts encrypted credentials', () {
        final original = createSampleSettings();
        final map = original.toMap();
        final restored = SupabaseSettings.fromMap(map);

        expect(restored.email, equals('user@example.com'));
        expect(restored.password, equals('testPassword'));
      });

      test('fromMap handles legacy unencrypted data (backward compat)', () {
        final legacyMap = {
          'supabase_url': 'https://test.supabase.co',
          'supabase_anon_key': 'key123',
          'email': 'plain@example.com',
          'password': 'plainPassword',
          // No 'credentials_encrypted' key = legacy format
        };
        final settings = SupabaseSettings.fromMap(legacyMap);

        expect(settings.email, equals('plain@example.com'));
        expect(settings.password, equals('plainPassword'));
      });

      test('empty fields are not encrypted', () {
        final settings = SupabaseSettings.empty();
        final map = settings.toMap();

        expect(map['email'], equals(''));
        expect(map['password'], equals(''));
      });
    });
  });
}
