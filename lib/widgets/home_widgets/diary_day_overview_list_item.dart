import 'package:SimpleDiary/model/day/diary_day.dart';
import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:SimpleDiary/widgets/home_widgets/diary_day_notes_overview_list_item.dart';
import 'package:SimpleDiary/widgets/home_widgets/diary_day_overview_rating_list_item.dart';
import 'package:flutter/material.dart';

class DiaryDayOverviewListItem extends StatefulWidget {
  const DiaryDayOverviewListItem(
      {super.key, required this.diaryDay, required this.onSelectDiaryDay});

  final DiaryDay diaryDay;
  final void Function(DiaryDay diaryDay) onSelectDiaryDay;

  @override
  State<DiaryDayOverviewListItem> createState() =>
      _DiaryDayOverviewListItemState();
}

class _DiaryDayOverviewListItemState extends State<DiaryDayOverviewListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onBackground,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          widget.onSelectDiaryDay(widget.diaryDay);
        },
        child: Column(
          children: [
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Text(
                    '${widget.diaryDay.day.day}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                        ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Utils.printMonth(widget.diaryDay.day),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: getColor(widget.diaryDay),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.diaryDay.overallScore.toString(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  DiaryDayOverviewRatingListItem(
                      diaryDayRating: widget.diaryDay.ratings[0]),
                  DiaryDayOverviewRatingListItem(
                      diaryDayRating: widget.diaryDay.ratings[1]),
                  DiaryDayOverviewRatingListItem(
                      diaryDayRating: widget.diaryDay.ratings[2]),
                  DiaryDayOverviewRatingListItem(
                      diaryDayRating: widget.diaryDay.ratings[3]),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 650),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, index) => DiaryDayNotesOverviewListItem(
                  note: widget.diaryDay.notes[index],
                  onSelectNote: (Note note) {},
                ),
                itemCount: widget.diaryDay.notes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColor(DiaryDay diaryDay) {
    switch (diaryDay.overallScore) {
      case <= 5:
        return Colors.red;
      case <= 10:
        return const Color.fromARGB(255, 249, 119, 99);
      case <= 13:
        return Colors.yellow;
      case <= 17:
        return Colors.lightGreen;
      default:
        return Colors.green;
    }
  }
}
