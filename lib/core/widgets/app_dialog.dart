import 'dart:ui';

import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// A standardized dialog widget with consistent styling.
///
/// Provides a uniform look for all dialogs in the app, with theme-aware
/// colors for correct dark/light mode rendering.
///
/// Use the static helper methods for common dialog patterns:
/// - [AppDialog.confirm] — yes/no confirmation dialog
/// - [AppDialog.info] — informational dialog with a single dismiss button
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.actions,
    this.icon,
    this.maxWidth = 400,
    this.useGlass = false,
  });

  final String title;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final IconData? icon;
  final double maxWidth;

  /// When `true`, the dialog uses a frosted-glass background with blur effect.
  final bool useGlass;

  /// Shows a confirmation dialog and returns `true` if confirmed, `false` otherwise.
  ///
  /// [confirmLabel] and [cancelLabel] default to "OK" and "Cancel".
  /// Set [isDestructive] to `true` to style the confirm button as a warning.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows an informational dialog with a single dismiss button.
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    String dismissLabel = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        icon: icon,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(dismissLabel),
          ),
        ],
      ),
    );
  }

  /// Shows this dialog using [showDialog].
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dialogContent = Padding(
      padding: AppSpacing.paddingAllXl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            AppSpacing.verticalMd,
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (content != null || contentWidget != null) ...[
            AppSpacing.verticalMd,
            contentWidget ??
                Text(
                  content!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            AppSpacing.verticalXl,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!
                  .expand(
                      (action) => [AppSpacing.horizontalXs, action])
                  .skip(1)
                  .toList(),
            ),
          ],
        ],
      ),
    );

    if (useGlass) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusXl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: AppRadius.borderRadiusXl,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: dialogContent,
            ),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: dialogContent,
      ),
    );
  }
}
