import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_overview_list_item.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_wizard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/diary_day_detail_page.dart';

class DiaryDayOverviewList extends ConsumerStatefulWidget {
  const DiaryDayOverviewList({super.key});

  @override
  ConsumerState<DiaryDayOverviewList> createState() => _DiaryDayOverviewListState();
}

class _DiaryDayOverviewListState extends ConsumerState<DiaryDayOverviewList> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesLocalDataProvider);
    return notes.isEmpty ? _buildEmptyList() : _buildFilledList();
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No diary entries yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your day by adding notes\nand completing daily evaluations',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NoteWizardPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Today\'s Journal'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledList() {
    final diaryDays = ref.watch(diaryDayFullDataProvider);
    // Sort by date (most recent first)
    diaryDays.sort((a, b) => b.day.compareTo(a.day));

    return ListView.builder(
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(diaryDays[index].day),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                'Are you sure you want to delete this diary entry?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onRemoveDiaryDay(diaryDays[index]);
        },
        child: DiaryDayOverviewListItem(
          diaryDay: diaryDays[index],
          onSelectDiaryDay: onSelectDiaryDay,
        ),
      ),
      itemCount: diaryDays.length,
    );
  }

  void onSelectDiaryDay(DiaryDay diaryDay) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiaryDayDetailPage(selectedDate: diaryDay.day),
      ),
    );
  }

  void onRemoveDiaryDay(DiaryDay removedDiaryDay) {
    ref.read(diaryDayLocalDbDataProvider.notifier).deleteElement(removedDiaryDay);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Diary entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(diaryDayLocalDbDataProvider.notifier).addElement(removedDiaryDay);
          },
        ),
      ),
    );
  }
}
