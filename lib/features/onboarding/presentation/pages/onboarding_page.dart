import 'package:day_tracker/core/services/onboarding_service.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/onboarding/domain/providers/onboarding_provider.dart';
import 'package:day_tracker/features/onboarding/presentation/pages/setup_wizard_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Page model ────────────────────────────────────────────────────────────────

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

// ── Main widget ───────────────────────────────────────────────────────────────

/// Full-screen swipeable onboarding flow shown once on first launch.
///
/// On completion the widget sets [onboardingCompletedProvider] so that
/// [MainPage] re-evaluates the routing decision reactively.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  static const List<IconData> _pageIcons = [
    Icons.menu_book_rounded,
    Icons.star_rounded,
    Icons.calendar_today_rounded,
    Icons.insights_rounded,
    Icons.rocket_launch_rounded,
  ];

  List<_OnboardingPageData> _buildPages(AppLocalizations l10n) => [
        _OnboardingPageData(
          icon: _pageIcons[0],
          title: l10n.onboardingWelcomeTitle,
          description: l10n.onboardingWelcomeDescription,
        ),
        _OnboardingPageData(
          icon: _pageIcons[1],
          title: l10n.onboardingRatingsTitle,
          description: l10n.onboardingRatingsDescription,
        ),
        _OnboardingPageData(
          icon: _pageIcons[2],
          title: l10n.onboardingNotesTitle,
          description: l10n.onboardingNotesDescription,
        ),
        _OnboardingPageData(
          icon: _pageIcons[3],
          title: l10n.onboardingInsightsTitle,
          description: l10n.onboardingInsightsDescription,
        ),
        _OnboardingPageData(
          icon: _pageIcons[4],
          title: l10n.onboardingGetStartedTitle,
          description: l10n.onboardingGetStartedDescription,
        ),
      ];

  static const int _pageCount = 5;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _skip() => _goToPage(_pageCount - 1);

  // ── Completion handlers ───────────────────────────────────────────────────

  Future<void> _onExploreDemo() async {
    setState(() => _isLoading = true);
    try {
      await OnboardingService().markOnboardingComplete(isDemoMode: true);
      ref.read(isDemoModeProvider.notifier).state = true;
      ref.read(onboardingCompletedProvider.notifier).state = true;
      ref.read(userDataProvider.notifier).createDemoUser();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onCreateAccount() async {
    await OnboardingService().markOnboardingComplete(isDemoMode: false);
    ref.read(onboardingCompletedProvider.notifier).state = true;
    if (!mounted) return;
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const SetupWizardPage()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pages = _buildPages(l10n);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingAllSm,
                child: AnimatedOpacity(
                  opacity: _isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AppButton.text(
                    onPressed: _isLastPage ? null : _skip,
                    label: l10n.onboardingSkip,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _buildPage(context, theme, l10n, pages[index]),
              ),
            ),

            // Dots + bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDots(theme),
                  AppSpacing.verticalLg,
                  _buildBottomButtons(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, ThemeData theme, AppLocalizations l10n,
      _OnboardingPageData data) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 72,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.verticalXxl,

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          // Action buttons on last page
          if (_isLastPage) ...[
            AppSpacing.verticalXxl,
            AppButton.filled(
              onPressed: _isLoading ? null : _onExploreDemo,
              label: l10n.onboardingExploreDemo,
              icon: Icons.explore_rounded,
              isLoading: _isLoading,
              isExpanded: true,
              size: AppButtonSize.large,
            ),
            AppSpacing.verticalSm,
            AppButton.outlined(
              onPressed: _isLoading ? null : _onCreateAccount,
              label: l10n.onboardingCreateAccount,
              icon: Icons.person_add_rounded,
              isExpanded: true,
              size: AppButtonSize.large,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pageCount,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.4),
            borderRadius: AppRadius.borderRadiusSm,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    if (_isLastPage) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: AppButton.filled(
            onPressed: _goNext,
            label: l10n.onboardingNext,
            icon: Icons.arrow_forward_rounded,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
