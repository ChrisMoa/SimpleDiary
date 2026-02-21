import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_overview_list_item.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/core/navigation/drawer_index_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/diary_day_detail_page.dart';

class DiaryDayOverviewList extends ConsumerStatefulWidget {
  const DiaryDayOverviewList({super.key});

  @override
  ConsumerState<DiaryDayOverviewList> createState() =>
      _DiaryDayOverviewListState();
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          AppSpacing.verticalMd,
          Text(
            'No diary entries yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalXs,
          Text(
            'Start tracking your day by adding notes\nand completing daily evaluations',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.verticalXl,
          ElevatedButton.icon(
            onPressed: () {
              ref.read(selectedDrawerIndexProvider.notifier).state = 3;
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
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await AppDialog.confirm(
            context,
            title: 'Confirm Deletion',
            content: 'Are you sure you want to delete this diary entry?',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
            isDestructive: true,
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
    ref
        .read(diaryDayLocalDbDataProvider.notifier)
        .deleteElement(removedDiaryDay);

    AppSnackBar.info(
      context,
      message: 'Diary entry deleted',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          ref
              .read(diaryDayLocalDbDataProvider.notifier)
              .addElement(removedDiaryDay);
        },
      ),
    );
  }
}
