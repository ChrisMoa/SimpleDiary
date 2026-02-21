import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
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

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final l10n = AppLocalizations.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            Text(
              l10n.settingsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalXl,

            // Theme Settings
            const ThemeSettingsWidget(),
            AppSpacing.verticalXl,

            // Language Settings
            const LanguageSettingsWidget(),
            AppSpacing.verticalXl,

            // Notification Settings
            const NotificationSettingsWidget(),
            AppSpacing.verticalXl,

            // Biometric Settings
            const BiometricSettingsWidget(),
            AppSpacing.verticalXl,

            // Backup Settings
            const BackupSettingsWidget(),
            AppSpacing.verticalXl,

            // Supabase Settings
            const SupabaseSettingsWidget(),
            AppSpacing.verticalXl,

            // Category Management
            _buildCategoryManagementSection(theme, isSmallScreen, l10n),
            AppSpacing.verticalXxl,

            // Save Settings Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: Text(
                  l10n.saveSettings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() async {
    try {
      LogWrapper.logger.i('Saving settings from settings page');
      await settingsContainer.saveSettings();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.success(context, message: l10n.settingsSavedSuccessfully);
      }
    } catch (e) {
      LogWrapper.logger.e('Error saving settings: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.error(context, message: l10n.errorSavingSettings(e.toString()));
      }
    }
  }

  //* build helper -----------------------------------------------------------------------------------------------------------------------------------

  Widget _buildCategoryManagementSection(ThemeData theme, bool isSmallScreen, AppLocalizations l10n) {
    return AppCard.elevated(
      borderRadius: AppRadius.borderRadiusMd,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: theme.colorScheme.primary,
                  size: isSmallScreen ? 24 : 28,
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.noteCategories,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalXxs,
                      Text(
                        l10n.manageCategoriesAndTags,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalMd,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CategoryManagementPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: Text(l10n.manageCategories),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
