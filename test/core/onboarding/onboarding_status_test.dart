import 'package:day_tracker/core/onboarding/onboarding_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingStatus', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ── factory ──────────────────────────────────────────────────────────────

    test('initial() returns not-completed, non-demo status', () {
      final status = OnboardingStatus.initial();

      expect(status.hasCompletedOnboarding, false);
      expect(status.isDemoMode, false);
      expect(status.completedAt, isNull);
    });

    test('load() returns initial values when prefs are empty', () async {
      final status = await OnboardingStatus.load();

      expect(status.hasCompletedOnboarding, false);
      expect(status.isDemoMode, false);
      expect(status.completedAt, isNull);
    });

    // ── markComplete ─────────────────────────────────────────────────────────

    test('markComplete() persists completed=true and demo=false', () async {
      await OnboardingStatus.markComplete();
      final status = await OnboardingStatus.load();

      expect(status.hasCompletedOnboarding, true);
      expect(status.isDemoMode, false);
      expect(status.completedAt, isNotNull);
    });

    test('markComplete(isDemoMode:true) persists demo=true', () async {
      await OnboardingStatus.markComplete(isDemoMode: true);
      final status = await OnboardingStatus.load();

      expect(status.hasCompletedOnboarding, true);
      expect(status.isDemoMode, true);
    });

    test('markComplete() stores a valid ISO-8601 completedAt timestamp', () async {
      final before = DateTime.now();
      await OnboardingStatus.markComplete();
      final after = DateTime.now();

      final status = await OnboardingStatus.load();

      expect(status.completedAt, isNotNull);
      expect(status.completedAt!.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(status.completedAt!.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    // ── clearDemoMode ─────────────────────────────────────────────────────────

    test('clearDemoMode() sets demo=false while keeping completed=true', () async {
      await OnboardingStatus.markComplete(isDemoMode: true);
      await OnboardingStatus.clearDemoMode();

      final status = await OnboardingStatus.load();
      expect(status.hasCompletedOnboarding, true);
      expect(status.isDemoMode, false);
    });

    // ── clear ─────────────────────────────────────────────────────────────────

    test('clear() resets all fields to defaults', () async {
      await OnboardingStatus.markComplete(isDemoMode: true);
      await OnboardingStatus.clear();

      final status = await OnboardingStatus.load();
      expect(status.hasCompletedOnboarding, false);
      expect(status.isDemoMode, false);
      expect(status.completedAt, isNull);
    });

    // ── toString ──────────────────────────────────────────────────────────────

    test('toString() includes key fields', () {
      final status = OnboardingStatus(
        hasCompletedOnboarding: true,
        isDemoMode: false,
        completedAt: DateTime(2026, 2, 21),
      );

      final str = status.toString();
      expect(str, contains('completed=true'));
      expect(str, contains('demo=false'));
    });

    // ── round-trip ────────────────────────────────────────────────────────────

    test('round-trip: markComplete → load → clear → load restores defaults', () async {
      await OnboardingStatus.markComplete(isDemoMode: true);
      final after = await OnboardingStatus.load();
      expect(after.hasCompletedOnboarding, true);
      expect(after.isDemoMode, true);

      await OnboardingStatus.clear();
      final cleared = await OnboardingStatus.load();
      expect(cleared.hasCompletedOnboarding, false);
      expect(cleared.isDemoMode, false);
    });
  });
}
