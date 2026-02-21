import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
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
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.horizontalLg,
        Text(
          diaryDayRating.score.toString(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.horizontalLg,
      ]),
    );
  }
}
