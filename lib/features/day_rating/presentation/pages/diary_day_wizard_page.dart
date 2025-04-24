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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    LogWrapper.logger.d('Loading data for diary day wizard');
    await ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();
    ref.read(noteSelectedDateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: const SafeArea(
          child: DiaryDayEditingWizardWidget(
            navigateBack: false,
            addAdditionalSaveButton: true,
            editNote: false,
          ),
        ),
      ),
    );
  }
}
