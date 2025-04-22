import 'package:day_tracker/core/provider/theme_provider.dart';
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
  ConsumerState<DiaryDayEditingWizardWidget> createState() =>
      _DiaryDayEditingWizardWidgetState();
}

class _DiaryDayEditingWizardWidgetState
    extends ConsumerState<DiaryDayEditingWizardWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Day selector
          const DateSelectorWidget(),
          const SizedBox(height: 16),

          // Body: Two columns - Calendar and Note detail
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Calendar (now includes New Note button)
                const Expanded(
                  flex: 3,
                  child: NotesCalendarWidget(),
                ),

                // Right column - Note Detail
                const Expanded(
                  flex: 2,
                  child: NoteDetailWidget(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Footer: Day Rating section
          const DayRatingWidget(),
        ],
      ),
    );
  }
}
