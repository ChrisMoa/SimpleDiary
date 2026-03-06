import 'dart:convert';

import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserData', () {
    UserData createSampleUser() {
      return UserData(
        username: 'testuser',
        password: 'hashedPassword123',
        salt: 'salt123',
        email: 'test@example.com',
        userId: 'user-uuid-123',
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final user = createSampleUser();
        expect(user.username, 'testuser');
        expect(user.password, 'hashedPassword123');
        expect(user.salt, 'salt123');
        expect(user.email, 'test@example.com');
        expect(user.userId, 'user-uuid-123');
        expect(user.isLoggedIn, false);
      });

      test('auto-generates userId if not provided', () {
        final user = UserData(
          username: 'test',
          password: 'pass',
          email: 'test@test.com',
        );
        expect(user.userId, isNotNull);
        expect(user.userId, isNotEmpty);
      });

      test('fromEmpty creates valid empty user', () {
        final user = UserData.fromEmpty();
        expect(user.username, '');
        expect(user.password, '');
        expect(user.salt, '');
        expect(user.email, '');
        expect(user.userId, isNotNull);
        expect(user.isLoggedIn, false);
      });

      test('defaults for all fields when not provided', () {
        final user = UserData();
        expect(user.username, '');
        expect(user.password, '');
        expect(user.salt, '');
        expect(user.email, '');
        expect(user.isLoggedIn, false);
        // ignore: deprecated_member_use
        expect(user.clearPassword, '');
        expect(user.sessionEncryptionKey, '');
      });
    });

    group('sessionEncryptionKey', () {
      test('is not included in toMap', () {
        final user = createSampleUser();
        user.sessionEncryptionKey = 'derivedKey123';

        final map = user.toMap();
        expect(map.containsKey('sessionEncryptionKey'), false);
        expect(map.values.contains('derivedKey123'), false);
      });

      test('getter and setter work', () {
        final user = createSampleUser();
        user.sessionEncryptionKey = 'myKey';
        expect(user.sessionEncryptionKey, 'myKey');
      });

      test('deprecated clearPassword getter returns empty string', () {
        final user = UserData(
          username: 'test',
          password: 'pass',
          sessionEncryptionKey: 'key123',
        );
        // ignore: deprecated_member_use
        expect(user.clearPassword, '');
      });

      test('constructor accepts sessionEncryptionKey', () {
        final user = UserData(
          username: 'test',
          sessionEncryptionKey: 'myEncKey',
        );
        expect(user.sessionEncryptionKey, 'myEncKey');
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSampleUser();
        final map = original.toMap();
        final restored = UserData.fromMap(map);

        expect(restored.username, original.username);
        expect(restored.password, original.password);
        expect(restored.salt, original.salt);
        expect(restored.email, original.email);
        expect(restored.userId, original.userId);
      });

      test('map contains correct keys', () {
        final user = createSampleUser();
        final map = user.toMap();

        expect(map, contains('username'));
        expect(map, contains('password'));
        expect(map, contains('salt'));
        expect(map, contains('email'));
        expect(map, contains('userId'));
      });

      test('fromMap handles empty salt for backward compatibility', () {
        final map = {
          'username': 'test',
          'password': 'pass',
          'email': 'test@test.com',
          'userId': 'id-123',
          // no 'salt' key
        };
        final user = UserData.fromMap(map);
        expect(user.salt, '');
      });
    });

    group('toJson / fromJson', () {
      test('round-trip through JSON string', () {
        final original = createSampleUser();
        final jsonStr = original.toJson();

        expect(() => json.decode(jsonStr), returnsNormally);

        final restored = UserData.fromJson(jsonStr);
        expect(restored.username, original.username);
        expect(restored.password, original.password);
        expect(restored.salt, original.salt);
        expect(restored.email, original.email);
        expect(restored.userId, original.userId);
      });
    });

  });
}
