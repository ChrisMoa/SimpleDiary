import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// A standardized section header widget for grouping content.
///
/// Displays a title with an optional trailing action widget (e.g. a button
/// or icon). Uses theme-aware colors for dark/light mode.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
    this.child,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...[
            AppSpacing.verticalXs,
            child!,
          ],
        ],
      ),
    );
  }
}
