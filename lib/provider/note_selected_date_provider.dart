import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteSelectedDateProvider extends StateNotifier<DateTime> {
  NoteSelectedDateProvider() : super(DateTime.now());

  void updateSelectedDate(DateTime newTime) {
    state = newTime;
  }
}

final noteSelectedDateProvider =
    StateNotifierProvider<NoteSelectedDateProvider, DateTime>(
  (ref) => NoteSelectedDateProvider(),
);
