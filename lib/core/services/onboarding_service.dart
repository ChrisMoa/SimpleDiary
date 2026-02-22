import 'package:day_tracker/core/onboarding/onboarding_status.dart';

/// Business logic for onboarding lifecycle.
///
/// Delegates persistence to [OnboardingStatus] (SharedPreferences).
class OnboardingService {
  /// Returns `true` when onboarding has not yet been completed.
  Future<bool> shouldShowOnboarding() async {
    final status = await OnboardingStatus.load();
    return !status.hasCompletedOnboarding;
  }

  /// Marks onboarding as done.
  ///
  /// Pass [isDemoMode] = true when the user chose "Explore Demo" rather
  /// than creating a real account.
  Future<void> markOnboardingComplete({bool isDemoMode = false}) async {
    await OnboardingStatus.markComplete(isDemoMode: isDemoMode);
  }

  /// Returns `true` when the current session is running on demo data.
  Future<bool> isDemoMode() async {
    final status = await OnboardingStatus.load();
    return status.isDemoMode;
  }

  /// Clears demo mode after the user creates a real account.
  Future<void> exitDemoMode() async {
    await OnboardingStatus.clearDemoMode();
  }

  /// Resets all onboarding state — for debug / "reset tutorial" feature.
  Future<void> resetOnboarding() async {
    await OnboardingStatus.clear();
  }
}
