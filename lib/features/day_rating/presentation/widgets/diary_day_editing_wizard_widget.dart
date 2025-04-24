import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_page_state_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/date_selector_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/day_rating_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/note_detail_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/notes_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryDayEditingWizardWidget extends ConsumerStatefulWidget {
  final bool navigateBack;
  final bool addAdditionalSaveButton;
  final bool editNote;

  const DiaryDayEditingWizardWidget({
    super.key,
    navigateBack,
    addAdditionalSaveButton,
    editNote,
  })  : navigateBack = navigateBack ?? true,
        addAdditionalSaveButton = addAdditionalSaveButton ?? false,
        editNote = editNote ?? false;

  @override
  ConsumerState<DiaryDayEditingWizardWidget> createState() => _DiaryDayEditingWizardWidgetState();
}

class _DiaryDayEditingWizardWidgetState extends ConsumerState<DiaryDayEditingWizardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Flag to track if we've already auto-navigated to ratings
  bool _hasAutoNavigatedToRatings = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isFullyScheduled = ref.watch(isDayFullyScheduledProvider);
    final pageState = ref.watch(diaryWizardPageStateProvider);
    final isRatingPage = pageState == DiaryWizardPageState.ratingPage;

    // Control animation based on current page
    if (isRatingPage && _animationController.status != AnimationStatus.completed) {
      _animationController.forward();
    } else if (!isRatingPage && _animationController.status != AnimationStatus.dismissed) {
      _animationController.reverse();
    }

    // Auto-navigate to ratings page when day is fully scheduled, but only once
    // and only if we're currently on the notes page
    if (isFullyScheduled && !isRatingPage && !_hasAutoNavigatedToRatings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(diaryWizardPageStateProvider.notifier).setRatingPage();
        _hasAutoNavigatedToRatings = true;
      });
    }

    return GestureDetector(
      // Close keyboard on tap outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: theme.colorScheme.background,
        child: Stack(
          children: [
            // Main content with animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Column(
                  children: [
                    // Date selector is visible on both pages
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateSelectorWidget(),
                    ),

                    // Main content area - Calendar/Notes or Ratings
                    Expanded(
                      child: Stack(
                        children: [
                          // Notes page
                          Positioned.fill(
                            child: Opacity(
                              opacity: 1 - _animation.value,
                              child: IgnorePointer(
                                ignoring: isRatingPage,
                                child: _buildNotesPage(),
                              ),
                            ),
                          ),

                          // Rating page
                          Positioned.fill(
                            child: Opacity(
                              opacity: _animation.value,
                              child: IgnorePointer(
                                ignoring: !isRatingPage,
                                child: _buildRatingPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preview/Navigation area
                    SizedBox(
                      height: 70,
                      child: _buildNavigationPreview(isRatingPage, isFullyScheduled),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Calendar (1/3 of space)
          Expanded(
            flex: 1,
            child: NotesCalendarWidget(),
          ),

          // Right column - Note Detail (2/3 of space)
          Expanded(
            flex: 2,
            child: NoteDetailWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DayRatingWidget(),
    );
  }

  Widget _buildNavigationPreview(bool isRatingPage, bool isFullyScheduled) {
    final theme = ref.watch(themeProvider);

    return InkWell(
      onTap: () {
        // Toggle between pages
        ref.read(diaryWizardPageStateProvider.notifier).togglePage();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Preview icon and text
            Icon(
              isRatingPage ? Icons.calendar_today : Icons.rate_review,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isRatingPage ? 'View and edit your schedule notes' : 'Rate your day experiences',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Navigation indicators
            Icon(
              isRatingPage ? Icons.chevron_left : Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
            if (!isFullyScheduled && !isRatingPage)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Fill day',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
