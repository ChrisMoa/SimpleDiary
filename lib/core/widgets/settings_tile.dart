import 'package:day_tracker/core/widgets/app_card.dart';
import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';

/// A standardized settings section with a header label and card body.
///
/// Replaces the repetitive pattern of section-header + AppCard.outlined
/// used across all settings widgets.
///
/// ```dart
/// SettingsSection(
///   title: 'Theme',
///   icon: Icons.palette,
///   children: [
///     SettingsTile(icon: Icons.dark_mode, title: 'Dark mode', trailing: Switch(...)),
///   ],
/// )
/// ```
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.headerTrailing,
    this.footer,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;
  final Widget? headerTrailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (headerTrailing != null) headerTrailing!,
            ],
          ),
        ),
        AppCard.outlined(
          margin: EdgeInsets.zero,
          borderRadius: AppRadius.borderRadiusLg,
          color: theme.colorScheme.surfaceContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(children.length * 2 - 1, (i) {
                if (i.isEven) return children[i ~/ 2];
                // Insert divider between items (but not for footers/custom widgets)
                return Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 54,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                );
              }),
              if (footer != null) ...[
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                footer!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single row in a settings section.
///
/// Shows an icon, title, optional subtitle, and a trailing control
/// (e.g. Switch, DropdownButton, ColorIndicator).
///
/// ```dart
/// SettingsTile(
///   icon: Icons.dark_mode_outlined,
///   title: 'Dark Mode',
///   subtitle: 'Toggle between light and dark',
///   trailing: Switch(value: isDark, onChanged: onChanged),
/// )
/// ```
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A settings tile where the control goes below the title row
/// instead of trailing inline (for wider controls like SegmentedButton, Slider).
///
/// ```dart
/// SettingsExpandedTile(
///   icon: Icons.calendar_today,
///   title: 'Frequency',
///   subtitle: 'How often to back up',
///   control: SegmentedButton<Freq>(...),
/// )
/// ```
class SettingsExpandedTile extends StatelessWidget {
  const SettingsExpandedTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.control,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 12),
            child: control,
          ),
        ],
      ),
    );
  }
}

/// A small status banner shown at the top of a settings section.
///
/// ```dart
/// SettingsStatusBanner.success(text: 'Last backup: 2h ago')
/// SettingsStatusBanner.warning(text: 'Backup overdue!')
/// ```
class SettingsStatusBanner extends StatelessWidget {
  const SettingsStatusBanner({
    super.key,
    required this.icon,
    required this.text,
    this.trailingText,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    this.trailingColor,
  });

  factory SettingsStatusBanner.success({
    required BuildContext context,
    required String text,
    String? trailingText,
  }) {
    final theme = Theme.of(context);
    return SettingsStatusBanner(
      icon: Icons.check_circle_outline,
      text: text,
      trailingText: trailingText,
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      iconColor: theme.colorScheme.primary,
      textColor: theme.colorScheme.onSurface,
    );
  }

  factory SettingsStatusBanner.warning({
    required BuildContext context,
    required String text,
    String? trailingText,
  }) {
    final theme = Theme.of(context);
    return SettingsStatusBanner(
      icon: Icons.warning_amber_rounded,
      text: text,
      trailingText: trailingText,
      backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      iconColor: theme.colorScheme.error,
      textColor: theme.colorScheme.onErrorContainer,
      trailingColor: theme.colorScheme.error,
    );
  }

  final IconData icon;
  final String text;
  final String? trailingText;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: trailingColor ?? textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
