import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSettingsWidget extends ConsumerWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    String currentLanguageName() {
      switch (locale.languageCode) {
        case 'de':
          return l10n.german;
        case 'es':
          return l10n.spanish;
        case 'fr':
          return l10n.french;
        default:
          return l10n.english;
      }
    }

    return SettingsSection(
      title: l10n.languageSettings,
      icon: Icons.translate,
      children: [
        SettingsTile(
          icon: Icons.language,
          title: l10n.language,
          subtitle: currentLanguageName(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: DropdownButton<String>(
              value: locale.languageCode,
              underline: const SizedBox.shrink(),
              isDense: true,
              dropdownColor: theme.colorScheme.surfaceContainer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              items: [
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                DropdownMenuItem(value: 'de', child: Text(l10n.german)),
                DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(newValue));
                  settingsContainer.saveSettings().ignore();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
