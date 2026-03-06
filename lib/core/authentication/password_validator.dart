import 'package:day_tracker/l10n/app_localizations.dart';

class PasswordValidator {
  static const int minLength = 12;

  /// Validates password strength and returns the first error message,
  /// or null if the password is valid.
  static String? validate(String? password, AppLocalizations l10n) {
    if (password == null || password.isEmpty) {
      return l10n.pleaseEnterPassword;
    }
    if (password.length < minLength) {
      return l10n.passwordMinLength;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return l10n.passwordRequiresUppercase;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return l10n.passwordRequiresLowercase;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return l10n.passwordRequiresNumber;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'))) {
      return l10n.passwordRequiresSpecialChar;
    }
    return null;
  }

  /// Returns a strength score from 0 to 5.
  static int strengthScore(String password) {
    var score = 0;
    if (password.length >= minLength) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'))) {
      score++;
    }
    return score;
  }
}
