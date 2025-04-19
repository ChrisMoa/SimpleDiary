import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DiaryDayRatingItem {
  DiaryDayRatingItem({required DayRatings dayRatings}) {
    dayRating = DayRating(dayRating: dayRatings);
    ratingBar = RatingBar.builder(
      initialRating: 3,
      itemCount: 5,
      allowHalfRating: false,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return const Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
            );
          case 1:
            return const Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.redAccent,
            );
          case 2:
            return const Icon(
              Icons.sentiment_neutral,
              color: Colors.amber,
            );
          case 3:
            return const Icon(
              Icons.sentiment_satisfied,
              color: Colors.lightGreen,
            );
          case 4:
            return const Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
            );
          default:
            return const Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
            );
        }
      },
      onRatingUpdate: (rating) {
        dayRating.score = rating.toInt();
      },
    );
  }

  late RatingBar ratingBar;
  late DayRating dayRating;
}
