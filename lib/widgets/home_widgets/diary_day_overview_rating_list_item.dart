import 'package:SimpleDiary/model/day/day_rating.dart';
import 'package:flutter/material.dart';

class DiaryDayOverviewRatingListItem extends StatelessWidget {
  const DiaryDayOverviewRatingListItem(
      {super.key, required this.diaryDayRating});

  final DayRating diaryDayRating;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(children: [
        Text(
          diaryDayRating.dayRating.name.substring(0, 3),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 20),
        Text(
          diaryDayRating.score.toString(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}
