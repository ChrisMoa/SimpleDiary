enum DayRatings {
  social,
  productivity,
  sport,
  food,
}

DayRatings stringToEnum(String value) {
  switch (value) {
    case 'social':
      return DayRatings.social;
    case 'productivity':
      return DayRatings.productivity;
    case 'sport':
      return DayRatings.sport;
    case 'food':
      return DayRatings.food;
    default:
      throw ArgumentError('Invalid enum string: $value');
  }
}

class DayRating {
  final DayRatings dayRating;
  int score;

  DayRating({required this.dayRating, this.score = -1});

  Map<String, dynamic> toMap() {
    return {
      'dayRating': dayRating.name,
      'score': score,
    };
  }

  factory DayRating.fromMap(Map<String, dynamic> map) {
    return DayRating(
      dayRating: stringToEnum(map['dayRating']),
      score: map['score'],
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'fields': {
        'dayRating': {'stringValue': dayRating.name},
        'score': {'integerValue': score},
      },
    };
  }

  factory DayRating.fromFirestoreMap(Map<String, dynamic> map) {
    return DayRating(
      dayRating: stringToEnum(map['dayRating']['stringValue']),
      score: int.parse(map['score']['integerValue']),
    );
  }
}
