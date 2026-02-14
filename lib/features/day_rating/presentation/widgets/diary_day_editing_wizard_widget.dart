import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/day_rating_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/note_detail_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/notes_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
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

class _DiaryDayEditingWizardWidgetState extends ConsumerState<DiaryDayEditingWizardWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // Screen size for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final screenWidth = mediaQuery.size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return GestureDetector(
      // Close keyboard on tap outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              // Main content area using tabbed navigation
              Expanded(
                child: _buildTabLayout(isTabletOrLarger, isKeyboardVisible, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabLayout(bool isTabletOrLarger, bool isKeyboardVisible, ThemeData theme) {
    // For tablets and larger screens in landscape, use horizontal layout
    if (isTabletOrLarger && !isKeyboardVisible && MediaQuery.of(context).orientation == Orientation.landscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: NotesCalendarWidget(),
          ),
          Expanded(
            flex: 2,
            child: NoteDetailWidget(),
          ),
          Expanded(
            flex: 2,
            child: DayRatingWidget(),
          ),
        ],
      );
    } else {
      // Phone layout or when keyboard is visible - use tabs
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Tab bar for navigation
            TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Icons.calendar_today),
                  text: AppLocalizations.of(context)!.calendar,
                ),
                Tab(
                  icon: const Icon(Icons.edit_note),
                  text: AppLocalizations.of(context)!.noteDetails,
                ),
                Tab(
                  icon: const Icon(Icons.rate_review_outlined),
                  text: AppLocalizations.of(context)!.dayRating,
                ),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: theme.colorScheme.primary,
            ),

            // Content area
            Expanded(
              child: TabBarView(
                children: [
                  // Calendar view
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NotesCalendarWidget(),
                  ),

                  // Note detail view
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NoteDetailWidget(),
                  ),

                  // Day rating view
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DayRatingWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
