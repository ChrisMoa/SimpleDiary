import 'package:SimpleDiary/model/day/day_rating.dart';
import 'package:SimpleDiary/model/day/diary_day.dart';
import 'package:SimpleDiary/model/diary_day_rating_item.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryDayEditingWizardWidget extends ConsumerStatefulWidget {
  final bool navigateBack;
  final bool addAdditionalSaveButton;
  final bool editNote;

  const DiaryDayEditingWizardWidget({
    Key? key,
    navigateBack,
    addAdditionalSaveButton,
    editNote,
    onSaveNote,
  })  : navigateBack = navigateBack ?? true,
        addAdditionalSaveButton = addAdditionalSaveButton ?? false,
        editNote = editNote ?? false,
        super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiaryDayEditingWizardWidget();
}

class _DiaryDayEditingWizardWidget extends ConsumerState<DiaryDayEditingWizardWidget> {
  DateTime selectedDate = DateTime.now().copyWith(hour: 0, second: 0, minute: 0);
  List<DiaryDayRatingItem> dayRatings = [];

  @override
  void initState() {
    super.initState();
    for (var element in DayRatings.values) {
      var diaryDayRatingItem = DiaryDayRatingItem(dayRatings: element);
      dayRatings.add(diaryDayRatingItem);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext contex) {
    selectedDate = ref.watch(noteSelectedDateProvider);

    return buildScaffoldBody(contex);
  }

  Widget buildScaffoldBody(BuildContext contex) => Form(
        child: Column(
          children: [
            buildRatingItems(0),
            const SizedBox(
              height: 10,
            ),
            buildRatingItems(1),
            const SizedBox(
              height: 10,
            ),
            buildRatingItems(2),
            const SizedBox(
              height: 10,
            ),
            buildRatingItems(3),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                saveRating();
              },
              child: Text(
                'save day',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      );

  Widget buildRatingItems(int index) {
    if (index < 0 || index >= dayRatings.length) {
      return const Text('Error during building rating items');
    }
    var dayRatingItem = dayRatings[index];
    return Row(
      children: [Text(dayRatingItem.dayRating.dayRating.name), const SizedBox(width: 20), dayRatingItem.ratingBar],
    );
  }

  void saveRating() async {
    LogWrapper.logger.t('saves now the diaryDate for day ${Utils.toDate(selectedDate)} to database');
    List<DayRating> ratings = [];
    for (var element in dayRatings) {
      ratings.add(element.dayRating);
    }
    var diaryDay = DiaryDay(day: selectedDate, ratings: ratings);
    ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
  }
}
