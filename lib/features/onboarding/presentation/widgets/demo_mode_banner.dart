import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/authentication/presentation/pages/auth_user_data_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Persistent banner displayed at the top of the main app while the user is
/// exploring with demo data. Tapping "Create Account" navigates to
/// [AuthUserDataPage]; the "×" button dismisses for the current session.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            AppSpacing.horizontalXs,
            Expanded(
              child: Text(
                l10n.demoModeBannerText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppButton.text(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(builder: (_) => const AuthUserDataPage()),
                );
              },
              label: l10n.demoModeCreateAccount,
              size: AppButtonSize.small,
              color: theme.colorScheme.tertiary,
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
