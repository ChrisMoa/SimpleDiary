import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseSettings', () {
    SupabaseSettings createSampleSettings() {
      return SupabaseSettings(
        supabaseUrl: 'http://localhost:8000',
        supabaseAnonKey: 'test-anon-key-123',
        email: 'user@example.com',
        password: 'testPassword',
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final settings = createSampleSettings();
        expect(settings.supabaseUrl, 'http://localhost:8000');
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

      test('map uses snake_case keys', () {
        final settings = createSampleSettings();
        final map = settings.toMap();

        expect(map, contains('supabase_url'));
        expect(map, contains('supabase_anon_key'));
        expect(map, contains('email'));
        expect(map, contains('password'));
      });

      test('fromMap handles missing keys with empty defaults', () {
        final settings = SupabaseSettings.fromMap({});
        expect(settings.supabaseUrl, '');
        expect(settings.supabaseAnonKey, '');
        expect(settings.email, '');
        expect(settings.password, '');
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
    });
  });
}
