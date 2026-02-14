import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/diary_day_editing_wizard_widget.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
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
    if (_isLoading) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingDayData),
          ],
        ),
      );
    }

    return const SafeArea(
      child: DiaryDayEditingWizardWidget(
        navigateBack: false,
        addAdditionalSaveButton: true,
        editNote: false,
      ),
    );
  }
}
