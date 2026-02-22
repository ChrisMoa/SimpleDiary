import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/authentication/presentation/pages/auth_user_data_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Two-step setup wizard shown only on the "Create Account" onboarding path.
///
/// Step 1 – dark / light theme toggle.
/// Step 2 – language selection (EN / DE / ES / FR).
///
/// "Done" navigates to [AuthUserDataPage] for actual account creation and
/// replaces the current route so the user cannot navigate back to onboarding.
class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const int _totalSteps = 2;

  bool get _isLastStep => _currentStep == _totalSteps - 1;

  void _goNext() {
    if (_isLastStep) {
      _onDone();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDone() {
    settingsContainer.saveSettings();
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => const AuthUserDataPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface),
          onPressed: _goBack,
        ),
        title: Text(
          l10n.setupWizardTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: AppSpacing.paddingAllMd,
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.2),
                color: theme.colorScheme.primary,
                borderRadius: AppRadius.borderRadiusSm,
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: const [
                  _ThemeStepPage(),
                  _LanguageStepPage(),
                ],
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: AppButton.filled(
                onPressed: _goNext,
                label: _isLastStep ? l10n.setupWizardDone : l10n.setupWizardNext,
                icon: _isLastStep
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                isExpanded: true,
                size: AppButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Theme ─────────────────────────────────────────────────────────────

class _ThemeStepPage extends ConsumerWidget {
  const _ThemeStepPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.paddingHorizontalLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          AppSpacing.verticalXl,
          Text(
            l10n.setupWizardThemeTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalSm,
          Text(
            l10n.setupWizardThemeHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalXxl,
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  label: l10n.setupWizardThemeLight,
                  icon: Icons.light_mode_rounded,
                  isSelected: !isDark,
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleDarkMode(false);
                    settingsContainer.activeUserSettings.darkThemeMode = false;
                  },
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: _ThemeOption(
                  label: l10n.setupWizardThemeDark,
                  icon: Icons.dark_mode_rounded,
                  isSelected: isDark,
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleDarkMode(true);
                    settingsContainer.activeUserSettings.darkThemeMode = true;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingAllLg,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainer,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            AppSpacing.verticalXs,
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Language ──────────────────────────────────────────────────────────

class _LanguageStepPage extends ConsumerWidget {
  const _LanguageStepPage();

  static const List<({String code, String label, String flag})> _languages = [
    (code: 'en', label: 'English', flag: '🇬🇧'),
    (code: 'de', label: 'Deutsch', flag: '🇩🇪'),
    (code: 'es', label: 'Español', flag: '🇪🇸'),
    (code: 'fr', label: 'Français', flag: '🇫🇷'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentCode = ref.watch(localeProvider).languageCode;

    return Padding(
      padding: AppSpacing.paddingHorizontalLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          AppSpacing.verticalXl,
          Text(
            l10n.setupWizardLanguageTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalSm,
          Text(
            l10n.setupWizardLanguageHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalXxl,
          ...(_languages.map(
            (lang) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _LanguageOption(
                code: lang.code,
                label: lang.label,
                flag: lang.flag,
                isSelected: currentCode == lang.code,
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(lang.code));
                },
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainer,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
