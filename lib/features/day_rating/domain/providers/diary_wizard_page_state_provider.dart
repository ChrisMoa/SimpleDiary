import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DiaryWizardPageState {
  notesPage,
  ratingPage,
}

class DiaryWizardPageStateNotifier extends StateNotifier<DiaryWizardPageState> {
  DiaryWizardPageStateNotifier() : super(DiaryWizardPageState.notesPage);

  void setNotesPage() {
    state = DiaryWizardPageState.notesPage;
  }

  void setRatingPage() {
    state = DiaryWizardPageState.ratingPage;
  }

  void togglePage() {
    state = state == DiaryWizardPageState.notesPage
        ? DiaryWizardPageState.ratingPage
        : DiaryWizardPageState.notesPage;
  }
}

final diaryWizardPageStateProvider =
    StateNotifierProvider<DiaryWizardPageStateNotifier, DiaryWizardPageState>(
  (ref) => DiaryWizardPageStateNotifier(),
);
