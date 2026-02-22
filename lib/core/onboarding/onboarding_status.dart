import 'package:shared_preferences/shared_preferences.dart';

/// Stores onboarding completion state in SharedPreferences.
///
/// Keys are device-global (not per-user) because onboarding is shown once
/// regardless of which account the user creates.
class OnboardingStatus {
  static const _keyCompleted = 'onboarding_completed';
  static const _keyDemoMode = 'onboarding_is_demo_mode';
  static const _keyCompletedAt = 'onboarding_completed_at';

  final bool hasCompletedOnboarding;
  final bool isDemoMode;
  final DateTime? completedAt;

  const OnboardingStatus({
    required this.hasCompletedOnboarding,
    required this.isDemoMode,
    this.completedAt,
  });

  factory OnboardingStatus.initial() => const OnboardingStatus(
        hasCompletedOnboarding: false,
        isDemoMode: false,
      );

  /// Reads the current status from SharedPreferences.
  static Future<OnboardingStatus> load() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_keyCompleted) ?? false;
    final demo = prefs.getBool(_keyDemoMode) ?? false;
    final atStr = prefs.getString(_keyCompletedAt);
    final at = atStr != null ? DateTime.tryParse(atStr) : null;
    return OnboardingStatus(
      hasCompletedOnboarding: completed,
      isDemoMode: demo,
      completedAt: at,
    );
  }

  /// Persists onboarding completion. Call once after the onboarding flow.
  static Future<void> markComplete({bool isDemoMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);
    await prefs.setBool(_keyDemoMode, isDemoMode);
    await prefs.setString(_keyCompletedAt, DateTime.now().toIso8601String());
  }

  /// Clears demo mode flag (called when a real account is created).
  static Future<void> clearDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDemoMode, false);
  }

  /// Resets all onboarding state — useful for debug/testing.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompleted);
    await prefs.remove(_keyDemoMode);
    await prefs.remove(_keyCompletedAt);
  }

  @override
  String toString() =>
      'OnboardingStatus(completed=$hasCompletedOnboarding, demo=$isDemoMode, at=$completedAt)';
}
