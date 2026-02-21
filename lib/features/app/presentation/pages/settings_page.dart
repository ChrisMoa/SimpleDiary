import 'package:day_tracker/features/app/presentation/widgets/language_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/backup_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/biometric_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/notification_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/supabase_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/theme_settings_widget.dart';
import 'package:day_tracker/features/notes/presentation/pages/category_management_page.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final sections = <Widget>[
      // Theme Settings
      const ThemeSettingsWidget(),

      // Language Settings
      const LanguageSettingsWidget(),

      // Notification Settings
      const NotificationSettingsWidget(),

      // Biometric Settings
      const BiometricSettingsWidget(),

      // Backup Settings
      const BackupSettingsWidget(),

      // Supabase / Cloud Sync Settings
      const SupabaseSettingsWidget(),

      // Category Management
      _buildCategorySection(context, theme, l10n),
    ];

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: PageGradientBackground(
        child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 0,
                child: Text(
                  l10n.settingsTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => AnimatedListItem(
                  index: index + 1,
                  child: sections[index],
                ),
                childCount: sections.length,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 48),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.noteCategories,
      icon: Icons.label_outline,
      children: [
        SettingsTile(
          icon: Icons.label_outline,
          title: l10n.manageCategories,
          subtitle: l10n.manageCategoriesAndTags,
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant),
          onTap: () => Navigator.of(context).push(
            AppPageRoute(
              builder: (context) => const CategoryManagementPage(),
            ),
          ),
        ),
      ],
    );
  }
}
