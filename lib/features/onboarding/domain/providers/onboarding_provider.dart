import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether onboarding has been completed on this device.
///
/// Initialised to `false`; set to `true` by [MainPage._onInitAsync] once
/// SharedPreferences has been queried, and updated by [OnboardingPage] when
/// the user completes or skips the tutorial.
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// Whether the current session is running on demo data.
///
/// Initialised to `false`; set to `true` by [MainPage._onInitAsync] when
/// SharedPreferences reports that the "Explore Demo" path was chosen. Cleared
/// when the user creates a real account.
final isDemoModeProvider = StateProvider<bool>((ref) => false);
