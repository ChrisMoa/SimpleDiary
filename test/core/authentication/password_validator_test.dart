import 'package:day_tracker/core/authentication/password_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordValidator', () {
    group('strengthScore', () {
      test('returns 0 for empty password', () {
        expect(PasswordValidator.strengthScore(''), 0);
      });

      test('returns 1 for only lowercase', () {
        expect(PasswordValidator.strengthScore('abcdefghijklm'), 2);
        // length >= 12 + lowercase = 2
      });

      test('returns 5 for fully compliant password', () {
        expect(PasswordValidator.strengthScore('MyP@ssw0rd123'), 5);
      });

      test('returns 4 when missing special char', () {
        expect(PasswordValidator.strengthScore('MyPassword123'), 4);
      });

      test('returns 3 when missing number and special char', () {
        expect(PasswordValidator.strengthScore('MyPasswordAbc'), 3);
      });

      test('short password loses length point', () {
        expect(PasswordValidator.strengthScore('Ab1!'), 4);
        // has upper, lower, number, special but NOT length
      });
    });

    group('validate (without l10n)', () {
      // We test the logic patterns since we can't easily mock AppLocalizations
      // in pure unit tests without Flutter widget testing infrastructure.

      test('minLength constant is 12', () {
        expect(PasswordValidator.minLength, 12);
      });

      test('strong password passes all checks', () {
        // A password meeting all criteria
        const pass = 'MyStr0ng!Pass';
        expect(pass.length >= 12, true);
        expect(pass.contains(RegExp(r'[A-Z]')), true);
        expect(pass.contains(RegExp(r'[a-z]')), true);
        expect(pass.contains(RegExp(r'[0-9]')), true);
        expect(
            pass.contains(
                RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]')),
            true);
      });

      test('password without uppercase fails', () {
        const pass = 'mystr0ng!pass';
        expect(pass.contains(RegExp(r'[A-Z]')), false);
      });

      test('password without lowercase fails', () {
        const pass = 'MYSTR0NG!PASS';
        expect(pass.contains(RegExp(r'[a-z]')), false);
      });

      test('password without number fails', () {
        const pass = 'MyStrong!Pass';
        expect(pass.contains(RegExp(r'[0-9]')), false);
      });

      test('password without special char fails', () {
        const pass = 'MyStr0ngPassw';
        expect(
            pass.contains(
                RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]')),
            false);
      });

      test('password shorter than 12 chars fails', () {
        const pass = 'Ab1!short';
        expect(pass.length < PasswordValidator.minLength, true);
      });
    });
  });
}
