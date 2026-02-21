import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the currently selected drawer index.
/// Allows child widgets (e.g. dashboard FAB) to navigate
/// within the main scaffold without pushing a new route.
final selectedDrawerIndexProvider = StateProvider<int>((ref) => 0);
