import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// A standardized snack bar utility that replaces inline SnackBar constructions.
///
/// Provides consistent styling with theme-aware colors for success, error,
/// and info variants. All variants use floating behavior and rounded corners.
abstract final class AppSnackBar {
  /// Shows a success snack bar with a green-tinted background.
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(context, message: message, type: _Type.success, duration: duration, action: action);
  }

  /// Shows an error snack bar with a red-tinted background.
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _show(context, message: message, type: _Type.error, duration: duration, action: action);
  }

  /// Shows an informational snack bar with the primary color.
  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(context, message: message, type: _Type.info, duration: duration, action: action);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required _Type type,
    required Duration duration,
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final Color backgroundColor;
    final Color foregroundColor;
    final IconData icon;

    switch (type) {
      case _Type.success:
        backgroundColor = theme.brightness == Brightness.dark
            ? const Color(0xFF1B5E20)
            : const Color(0xFF4CAF50);
        foregroundColor = Colors.white;
        icon = Icons.check_circle_outline;
      case _Type.error:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = theme.colorScheme.onError;
        icon = Icons.error_outline;
      case _Type.info:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        icon = Icons.info_outline;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            AppSpacing.horizontalXs,
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foregroundColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSm,
        ),
        duration: duration,
        action: action,
      ),
    );
  }
}

enum _Type { success, error, info }
