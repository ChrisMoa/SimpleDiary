import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Granular dashboard providers', () {
    late ProviderContainer container;

    DashboardStats makeStats({
      int currentStreak = 5,
      bool todayLogged = true,
      double averageScore = 14.0,
    }) {
      return DashboardStats(
        currentStreak: currentStreak,
        todayLogged: todayLogged,
        weekStats: WeekStats(
          averageScore: averageScore,
          completedDays: 4,
          categoryAverages: {},
          dailyScores: [],
        ),
        monthlyTrend: {},
        topActivities: [],
        insights: [],
      );
    }

    tearDown(() => container.dispose());

    group('currentStreakProvider', () {
      test('returns streak from dashboard stats', () async {
        final stats = makeStats(currentStreak: 7);
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        // Wait for the async provider to resolve
        await container.read(dashboardStatsProvider.future);

        expect(container.read(currentStreakProvider), 7);
      });

      test('returns 0 when stats not yet loaded', () {
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith(
            (_) => Future.delayed(const Duration(seconds: 10), () => makeStats()),
          ),
        ]);

        // Before future completes, valueOrNull is null → default 0
        expect(container.read(currentStreakProvider), 0);
      });

      test('updates when streak changes', () async {
        var streak = 3;
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith(
            (_) async => makeStats(currentStreak: streak),
          ),
        ]);

        await container.read(dashboardStatsProvider.future);
        expect(container.read(currentStreakProvider), 3);

        // Simulate streak change by invalidating
        streak = 10;
        container.invalidate(dashboardStatsProvider);
        await container.read(dashboardStatsProvider.future);
        expect(container.read(currentStreakProvider), 10);
      });
    });

    group('todayLoggedProvider', () {
      test('returns true when today is logged', () async {
        final stats = makeStats(todayLogged: true);
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);
        expect(container.read(todayLoggedProvider), true);
      });

      test('returns false when today is not logged', () async {
        final stats = makeStats(todayLogged: false);
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);
        expect(container.read(todayLoggedProvider), false);
      });

      test('returns false when stats not yet loaded', () {
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith(
            (_) => Future.delayed(const Duration(seconds: 10), () => makeStats()),
          ),
        ]);

        expect(container.read(todayLoggedProvider), false);
      });
    });

    group('weekAverageProvider', () {
      test('returns average from week stats', () async {
        final stats = makeStats(averageScore: 16.5);
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);
        expect(container.read(weekAverageProvider), 16.5);
      });

      test('returns 0.0 when stats not yet loaded', () {
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith(
            (_) => Future.delayed(const Duration(seconds: 10), () => makeStats()),
          ),
        ]);

        expect(container.read(weekAverageProvider), 0.0);
      });

      test('returns 0.0 for zero average', () async {
        final stats = makeStats(averageScore: 0.0);
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);
        expect(container.read(weekAverageProvider), 0.0);
      });
    });

    group('selective rebuild behavior', () {
      test('all granular providers derive from same dashboardStatsProvider', () async {
        final stats = makeStats(
          currentStreak: 5,
          todayLogged: true,
          averageScore: 12.0,
        );
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);

        expect(container.read(currentStreakProvider), 5);
        expect(container.read(todayLoggedProvider), true);
        expect(container.read(weekAverageProvider), 12.0);
      });

      test('providers return consistent values from shared source', () async {
        final stats = DashboardStats(
          currentStreak: 42,
          todayLogged: false,
          weekStats: WeekStats(
            averageScore: 18.3,
            completedDays: 7,
            categoryAverages: {'Work': 4.5},
            dailyScores: [],
          ),
          monthlyTrend: {'W1': 15.0},
          topActivities: ['Work'],
          insights: [
            Insight(
              type: InsightType.milestone,
              title: 'test',
              description: 'desc',
              icon: '🔥',
            ),
          ],
        );
        container = ProviderContainer(overrides: [
          dashboardStatsProvider.overrideWith((_) async => stats),
        ]);

        await container.read(dashboardStatsProvider.future);

        // Granular providers match the source stats
        expect(container.read(currentStreakProvider), stats.currentStreak);
        expect(container.read(todayLoggedProvider), stats.todayLogged);
        expect(
          container.read(weekAverageProvider),
          stats.weekStats.averageScore,
        );
      });
    });
  });
}
