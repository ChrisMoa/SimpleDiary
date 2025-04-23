import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/diary_day_editing_wizard_widget.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryDayWizardPage extends ConsumerStatefulWidget {
  const DiaryDayWizardPage({super.key});

  @override
  ConsumerState<DiaryDayWizardPage> createState() => _DiaryDayWizardPageState();
}

class _DiaryDayWizardPageState extends ConsumerState<DiaryDayWizardPage> {
  @override
  void initState() {
    super.initState();
    // Set initial date if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load saved notes for the selected date
      _loadData();
    });
  }

  Future<void> _loadData() async {
    LogWrapper.logger.d('Loading data for diary day wizard');

    // Load notes from database
    await ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();

    // Set selected date to today if not already set
    ref.read(noteSelectedDateProvider);

    // No need to create an initial empty note automatically
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Use the new DiaryDayEditingWizardWidget
              child: const DiaryDayEditingWizardWidget(
                navigateBack: false,
                addAdditionalSaveButton: true,
                editNote: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
