import 'package:day_tracker/core/onboarding/onboarding_status.dart';
import 'package:day_tracker/core/services/onboarding_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingService', () {
    late OnboardingService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = OnboardingService();
    });

    // ── shouldShowOnboarding ──────────────────────────────────────────────────

    test('shouldShowOnboarding() returns true when prefs are empty', () async {
      expect(await service.shouldShowOnboarding(), true);
    });

    test('shouldShowOnboarding() returns false after markOnboardingComplete', () async {
      await service.markOnboardingComplete();
      expect(await service.shouldShowOnboarding(), false);
    });

    test('shouldShowOnboarding() returns false after demo mode completion', () async {
      await service.markOnboardingComplete(isDemoMode: true);
      expect(await service.shouldShowOnboarding(), false);
    });

    // ── markOnboardingComplete ────────────────────────────────────────────────

    test('markOnboardingComplete() persists completion with demo=false by default', () async {
      await service.markOnboardingComplete();
      final status = await OnboardingStatus.load();

      expect(status.hasCompletedOnboarding, true);
      expect(status.isDemoMode, false);
    });

    test('markOnboardingComplete(isDemoMode:true) persists demo flag', () async {
      await service.markOnboardingComplete(isDemoMode: true);
      final status = await OnboardingStatus.load();

      expect(status.hasCompletedOnboarding, true);
      expect(status.isDemoMode, true);
    });

    // ── isDemoMode ────────────────────────────────────────────────────────────

    test('isDemoMode() returns false when prefs are empty', () async {
      expect(await service.isDemoMode(), false);
    });

    test('isDemoMode() returns false after normal completion', () async {
      await service.markOnboardingComplete(isDemoMode: false);
      expect(await service.isDemoMode(), false);
    });

    test('isDemoMode() returns true after demo completion', () async {
      await service.markOnboardingComplete(isDemoMode: true);
      expect(await service.isDemoMode(), true);
    });

    // ── exitDemoMode ──────────────────────────────────────────────────────────

    test('exitDemoMode() clears demo flag while keeping onboarding completed', () async {
      await service.markOnboardingComplete(isDemoMode: true);
      await service.exitDemoMode();

      expect(await service.isDemoMode(), false);
      expect(await service.shouldShowOnboarding(), false);
    });

    // ── resetOnboarding ───────────────────────────────────────────────────────

    test('resetOnboarding() causes shouldShowOnboarding to return true again', () async {
      await service.markOnboardingComplete();
      expect(await service.shouldShowOnboarding(), false);

      await service.resetOnboarding();
      expect(await service.shouldShowOnboarding(), true);
    });

    test('resetOnboarding() also clears demo mode', () async {
      await service.markOnboardingComplete(isDemoMode: true);
      await service.resetOnboarding();

      expect(await service.isDemoMode(), false);
    });

    // ── full lifecycle ────────────────────────────────────────────────────────

    test('demo lifecycle: complete → demo active → exit demo → onboarding still done', () async {
      // Fresh install
      expect(await service.shouldShowOnboarding(), true);
      expect(await service.isDemoMode(), false);

      // User taps "Explore Demo"
      await service.markOnboardingComplete(isDemoMode: true);
      expect(await service.shouldShowOnboarding(), false);
      expect(await service.isDemoMode(), true);

      // User later creates a real account
      await service.exitDemoMode();
      expect(await service.shouldShowOnboarding(), false);
      expect(await service.isDemoMode(), false);
    });

    test('normal lifecycle: complete → onboarding not shown again', () async {
      expect(await service.shouldShowOnboarding(), true);

      await service.markOnboardingComplete();
      expect(await service.shouldShowOnboarding(), false);
      expect(await service.isDemoMode(), false);

      // Simulate app restart (new service instance, same prefs)
      final service2 = OnboardingService();
      expect(await service2.shouldShowOnboarding(), false);
      expect(await service2.isDemoMode(), false);
    });
  });
}
