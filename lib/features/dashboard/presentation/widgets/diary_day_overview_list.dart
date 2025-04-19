import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_overview_list_item.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  //* build helper -----------------------------------------------------------------------------------------------------------------------------------

  Widget _buildEmptyList() {
    return const Text("There is no day fully recorded...Add a complete day");
  }

  Widget _buildFilledList() {
    final diaryDays = ref.watch(diaryDayFullDataProvider);
    diaryDays.sort((a, b) => b.day.compareTo(a.day));

    return ListView.builder(
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(diaryDays[index]),
        child: DiaryDayOverviewListItem(
          diaryDay: diaryDays[index],
          onSelectDiaryDay: onSelectDiaryDay,
        ),
        onDismissed: (direction) {
          onRemoveDiaryDay(diaryDays[index]);
        },
      ),
      itemCount: diaryDays.length,
    );
  }

  //* callbacks --------------------------------------------------------------------------------------------------------------------------------------

  void onSelectDiaryDay(DiaryDay diaryDay) {
    //
  }

  void onRemoveDiaryDay(DiaryDay removedDiaryDay) {
    ref
        .read(diaryDayLocalDbDataProvider.notifier)
        .deleteElement(removedDiaryDay);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('entry deleted!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref
                .read(diaryDayLocalDbDataProvider.notifier)
                .addElement(removedDiaryDay);
          },
        ),
      ),
    );
  }
}
