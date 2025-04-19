import 'dart:convert';

import 'package:day_tracker/core/database/local_db_element.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';

class DiaryDay implements LocalDbElement {
  DateTime day; //! the day for which the diary note is be done
  List<Note> notes = []; //! the list of connected notes
  List<DayRating> ratings;

  DiaryDay({
    required this.day,
    required this.ratings,
  });

  factory DiaryDay.fromEmpty() {
    return DiaryDay(day: DateTime.now(), ratings: []);
  }

  int get overallScore {
    int overallScore = 0;
    for (var value in ratings) {
      overallScore += value.score;
    }
    return overallScore;
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> ratingsList = [];
    for (var rating in ratings) {
      ratingsList.add(rating.toMap());
    }
    List<Map<String, dynamic>> notesList = [];
    for (var note in notes) {
      notesList.add(note.toMap());
    }

    return {
      'day': Utils.toDate(day),
      'ratings': ratingsList,
      'notes': notesList,
    };
  }

  factory DiaryDay.fromMap(Map<String, dynamic> map) {
    List<DayRating> ratings = [];
    for (Map<String, dynamic> rating in map['ratings']) {
      ratings.add(DayRating.fromMap(rating));
    }
    List<Note> noteList = [];
    for (Map<String, dynamic> notes in map['notes']) {
      noteList.add(Note.fromMap(notes));
    }
    var diaryDay = DiaryDay(day: Utils.fromDate(map['day']), ratings: ratings);
    diaryDay.notes = noteList;
    return diaryDay;
  }

  factory DiaryDay.fromLocalDbMap(Map<String, dynamic> map) {
    List<DayRating> ratings = [];
    var ratingsList = jsonDecode(map['ratings']);
    for (var rating in ratingsList) {
      try {
        ratings.add(DayRating.fromMap(rating));
      } catch (e) {
        LogWrapper.logger.e('cannot read $rating');
      }
    }
    return DiaryDay(day: Utils.fromDate(map['day']), ratings: ratings);
  }

  @override
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map) {
    List<DayRating> ratings = [];
    var ratingsList = jsonDecode(map['ratings']);
    for (var rating in ratingsList) {
      try {
        ratings.add(DayRating.fromMap(rating));
      } catch (e) {
        LogWrapper.logger.e('cannot read $rating');
      }
    }
    return DiaryDay(day: Utils.fromDate(map['day']), ratings: ratings);
  }

  @override
  Map<String, dynamic> toLocalDbMap(LocalDbElement map) {
    var ddMap = map as DiaryDay;
    List<Map<String, dynamic>> ratingsList = [];
    for (var rating in ddMap.ratings) {
      ratingsList.add(rating.toMap());
    }
    return {
      'day': Utils.toDate(ddMap.day),
      'ratings': jsonEncode(ratingsList),
    };
  }

  @override
  getId() {
    return Utils.toDate(day);
  }
}
