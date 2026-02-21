import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// The visual style variant of an [AppCard].
enum AppCardVariant {
  /// Flat card with no elevation, uses surface color.
  flat,

  /// Elevated card with subtle shadow.
  elevated,

  /// Outlined card with a border and no elevation.
  outlined,
}

/// A standardized card widget that replaces inline Card constructions.
///
/// Supports three visual variants: [AppCardVariant.flat],
/// [AppCardVariant.elevated], and [AppCardVariant.outlined].
///
/// Uses theme-aware colors so it works correctly in both light and dark mode.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  /// Creates a flat card with no elevation.
  const AppCard.flat({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppCardVariant.flat;

  /// Creates an elevated card with a subtle shadow.
  const AppCard.elevated({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppCardVariant.elevated;

  /// Creates an outlined card with a border.
  const AppCard.outlined({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppCardVariant.outlined;

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? AppRadius.borderRadiusLg;

    final double elevation;
    final Color cardColor;
    final BorderSide? borderSide;

    switch (variant) {
      case AppCardVariant.flat:
        elevation = AppElevation.flat;
        cardColor = color ?? theme.colorScheme.surfaceContainerLow;
        borderSide = null;
      case AppCardVariant.elevated:
        elevation = AppElevation.low;
        cardColor = color ?? theme.colorScheme.surface;
        borderSide = null;
      case AppCardVariant.outlined:
        elevation = AppElevation.flat;
        cardColor = color ?? theme.colorScheme.surface;
        borderSide = BorderSide(
          color: borderColor ?? theme.colorScheme.outlineVariant,
        );
    }

    final card = Card(
      elevation: elevation,
      shadowColor: elevation > 0
          ? theme.colorScheme.shadow.withValues(alpha: 0.3)
          : Colors.transparent,
      color: cardColor,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: borderSide ?? BorderSide.none,
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap != null || onLongPress != null) {
      return card.copyWith(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveRadius,
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      );
    }

    return card;
  }
}

extension on Card {
  Card copyWith({Widget? child}) {
    return Card(
      key: key,
      color: color,
      shadowColor: shadowColor,
      elevation: elevation,
      shape: shape,
      margin: margin,
      child: child ?? this.child,
    );
  }
}
