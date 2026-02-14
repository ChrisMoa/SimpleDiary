import 'package:day_tracker/core/utils/debug_auto_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugAutoLogin', () {
    group('isEnabled', () {
      test('returns true when DEBUG_AUTO_LOGIN is true (in debug mode)', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_AUTO_LOGIN': 'true',
        });
        // In test environment kDebugMode is true
        expect(DebugAutoLogin.isEnabled, true);
      });

      test('returns false when DEBUG_AUTO_LOGIN is not set', () {
        dotenv.testLoad(mergeWith: {});
        expect(DebugAutoLogin.isEnabled, false);
      });

      test('returns false when DEBUG_AUTO_LOGIN is false', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_AUTO_LOGIN': 'false',
        });
        expect(DebugAutoLogin.isEnabled, false);
      });

      test('returns false when DEBUG_AUTO_LOGIN is arbitrary string', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_AUTO_LOGIN': 'yes',
        });
        expect(DebugAutoLogin.isEnabled, false);
      });
    });

    group('credentials', () {
      test('returns values from dotenv', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': 'testuser',
          'DEBUG_PASSWORD': 'testpass123',
          'DEBUG_EMAIL': 'test@test.com',
        });
        expect(DebugAutoLogin.username, 'testuser');
        expect(DebugAutoLogin.password, 'testpass123');
        expect(DebugAutoLogin.email, 'test@test.com');
      });

      test('returns empty strings when env vars not set', () {
        dotenv.testLoad(mergeWith: {});
        expect(DebugAutoLogin.username, '');
        expect(DebugAutoLogin.password, '');
        expect(DebugAutoLogin.email, '');
      });
    });

    group('hasValidCredentials', () {
      test('returns true with valid username and password >= 8 chars', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': 'testuser',
          'DEBUG_PASSWORD': 'testpass123',
        });
        expect(DebugAutoLogin.hasValidCredentials, true);
      });

      test('returns false with empty username', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': '',
          'DEBUG_PASSWORD': 'testpass123',
        });
        expect(DebugAutoLogin.hasValidCredentials, false);
      });

      test('returns false with no username set', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_PASSWORD': 'testpass123',
        });
        expect(DebugAutoLogin.hasValidCredentials, false);
      });

      test('returns false with short password (< 8 chars)', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': 'testuser',
          'DEBUG_PASSWORD': 'short',
        });
        expect(DebugAutoLogin.hasValidCredentials, false);
      });

      test('returns false with empty password', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': 'testuser',
          'DEBUG_PASSWORD': '',
        });
        expect(DebugAutoLogin.hasValidCredentials, false);
      });

      test('returns true with password exactly 8 chars', () {
        dotenv.testLoad(mergeWith: {
          'DEBUG_USERNAME': 'testuser',
          'DEBUG_PASSWORD': '12345678',
        });
        expect(DebugAutoLogin.hasValidCredentials, true);
      });
    });
  });
}
