import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteSelectedDateProvider extends StateNotifier<DateTime> {
  final Ref ref;

  NoteSelectedDateProvider(this.ref) : super(DateTime.now());

  void updateSelectedDate(DateTime newDate) {
    // Normalize the date to keep just the date part (not time) for comparison
    final normalizedNewDate = DateTime(newDate.year, newDate.month, newDate.day);
    final normalizedOldDate = DateTime(state.year, state.month, state.day);

    if (normalizedNewDate != normalizedOldDate) {
      // Reset selection when date changes
      ref.read(selectedWizardNoteProvider.notifier).resetSelection();

      // Set the state with the full original date (preserving time)
      state = newDate;

      LogWrapper.logger.d('Selected date updated to: ${normalizedNewDate.toIso8601String()}');
    } else if (newDate != state) {
      // If only the time part changed, still update but don't reset selection
      state = newDate;
    }
  }
}

final noteSelectedDateProvider = StateNotifierProvider<NoteSelectedDateProvider, DateTime>((ref) {
  return NoteSelectedDateProvider(ref);
});
