import 'package:day_tracker/features/day_rating/data/models/rating_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsKey = 'rating_preferences_v1';

/// Riverpod provider for [RatingPreferences].
///
/// Persists to [SharedPreferences] automatically on every state change.
final ratingPreferencesProvider =
    StateNotifierProvider<RatingPreferencesNotifier, RatingPreferences>(
  (ref) => RatingPreferencesNotifier(),
);

class RatingPreferencesNotifier extends StateNotifier<RatingPreferences> {
  RatingPreferencesNotifier() : super(const RatingPreferences()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kPrefsKey);
    if (json != null && json.isNotEmpty) {
      try {
        state = RatingPreferences.fromJson(json);
      } catch (_) {
        // Corrupt data – keep defaults.
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, state.toJson());
  }

  void update(RatingPreferences preferences) {
    state = preferences;
    _save();
  }

  void setMode(RatingMode mode) {
    state = state.copyWith(mode: mode);
    _save();
  }

  void setUseLegacyMode(bool value) {
    state = state.copyWith(useLegacyMode: value);
    _save();
  }

  void setShowQuickMood(bool value) {
    state = state.copyWith(showQuickMood: value);
    _save();
  }

  void setShowEmotionWheel(bool value) {
    state = state.copyWith(showEmotionWheel: value);
    _save();
  }

  void setShowContextFactors(bool value) {
    state = state.copyWith(showContextFactors: value);
    _save();
  }

  void toggleDimension(String dimension) {
    final current = List<String>.from(state.enabledDimensions);
    if (current.contains(dimension)) {
      current.remove(dimension);
    } else {
      current.add(dimension);
    }
    state = state.copyWith(enabledDimensions: current);
    _save();
  }
}
