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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    LogWrapper.logger.d('Loading data for diary day wizard');
    await ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();
    ref.read(noteSelectedDateProvider);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the AppBar to save vertical space
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your day data...'),
                ],
              ),
            )
          : const SafeArea(
              child: DiaryDayEditingWizardWidget(
                navigateBack: false,
                addAdditionalSaveButton: true,
                editNote: false,
              ),
            ),
      // Using resizeToAvoidBottomInset: false to prevent the keyboard
      // from automatically pushing up the content
      resizeToAvoidBottomInset: false,
    );
  }
}
