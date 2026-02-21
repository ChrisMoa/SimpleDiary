import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// The visual style variant of an [AppButton].
enum AppButtonVariant {
  filled,
  elevated,
  outlined,
  text,
}

/// The size of an [AppButton].
enum AppButtonSize {
  small,
  medium,
  large,
}

/// A standardized button widget that replaces inline button constructions.
///
/// Supports four variants and three sizes, with an optional loading state.
/// All colors are theme-aware for correct dark/light mode rendering.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.color,
  });

  /// Creates a filled (primary) button.
  const AppButton.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.color,
  }) : variant = AppButtonVariant.filled;

  /// Creates an elevated button (subtle background with shadow).
  const AppButton.elevated({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.color,
  }) : variant = AppButtonVariant.elevated;

  /// Creates an outlined button.
  const AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.color,
  }) : variant = AppButtonVariant.outlined;

  /// Creates a text-only button.
  const AppButton.text({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.color,
  }) : variant = AppButtonVariant.text;

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final Color? color;

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle? _textStyle(ThemeData theme) {
    switch (size) {
      case AppButtonSize.small:
        return theme.textTheme.labelSmall;
      case AppButtonSize.medium:
        return theme.textTheme.labelLarge;
      case AppButtonSize.large:
        return theme.textTheme.titleSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget buttonChild = _buildChild(theme);

    final ButtonStyle style = _buildStyle(theme);

    Widget button;

    switch (variant) {
      case AppButtonVariant.filled:
        button = icon != null && !isLoading
            ? FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: _iconSize),
                label: buttonChild,
                style: style,
              )
            : FilledButton(
                onPressed: effectiveOnPressed,
                style: style,
                child: buttonChild,
              );
      case AppButtonVariant.elevated:
        button = icon != null && !isLoading
            ? ElevatedButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: _iconSize),
                label: buttonChild,
                style: style,
              )
            : ElevatedButton(
                onPressed: effectiveOnPressed,
                style: style,
                child: buttonChild,
              );
      case AppButtonVariant.outlined:
        button = icon != null && !isLoading
            ? OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: _iconSize),
                label: buttonChild,
                style: style,
              )
            : OutlinedButton(
                onPressed: effectiveOnPressed,
                style: style,
                child: buttonChild,
              );
      case AppButtonVariant.text:
        button = icon != null && !isLoading
            ? TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: _iconSize),
                label: buttonChild,
                style: style,
              )
            : TextButton(
                onPressed: effectiveOnPressed,
                style: style,
                child: buttonChild,
              );
    }

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foregroundColor(theme),
        ),
      );
    }
    return Text(label, style: _textStyle(theme));
  }

  Color? _foregroundColor(ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.filled:
        return color != null ? theme.colorScheme.onPrimary : null;
      case AppButtonVariant.elevated:
        return color ?? theme.colorScheme.primary;
      case AppButtonVariant.outlined:
        return color ?? theme.colorScheme.primary;
      case AppButtonVariant.text:
        return color ?? theme.colorScheme.primary;
    }
  }

  ButtonStyle _buildStyle(ThemeData theme) {
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusMd,
    );

    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton.styleFrom(
          padding: _padding,
          shape: shape,
          backgroundColor: color,
        );
      case AppButtonVariant.elevated:
        return ElevatedButton.styleFrom(
          padding: _padding,
          shape: shape,
          backgroundColor: color != null
              ? color!.withValues(alpha: 0.15)
              : theme.colorScheme.primaryContainer,
          foregroundColor: color ?? theme.colorScheme.onPrimaryContainer,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          padding: _padding,
          shape: shape,
          foregroundColor: color ?? theme.colorScheme.primary,
          side: BorderSide(
            color: color ?? theme.colorScheme.outline,
          ),
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(
          padding: _padding,
          shape: shape,
          foregroundColor: color ?? theme.colorScheme.primary,
        );
    }
  }
}
