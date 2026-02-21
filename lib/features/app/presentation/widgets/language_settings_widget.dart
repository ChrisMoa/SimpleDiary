import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSettingsWidget extends ConsumerWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return AppCard.elevated(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.language,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.languageSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              Text(
                l10n.languageDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalMd,
                    DropdownButtonFormField<String>(
                      value: locale.languageCode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        prefixIcon: Icon(
                          Icons.language,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l10n.english),
                        ),
                        DropdownMenuItem(
                          value: 'de',
                          child: Text(l10n.german),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text(l10n.spanish),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text(l10n.french),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(Locale(newValue));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
