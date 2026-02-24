import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/new_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestSettingsContainer();
  });

  group('NewDashboardPage', () {
    testWidgets('renders Scaffold with FAB', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB shows "New Entry" label with add icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Entry'), findsOneWidget);
      // Icon may appear in both FAB and child widgets
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('has RefreshIndicator for pull-to-refresh', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('uses mobile layout on narrow screen', (tester) async {
      // Set surface to mobile width (<600 breakpoint)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // Mobile layout uses CustomScrollView with many SliverToBoxAdapters
      expect(find.byType(CustomScrollView), findsAtLeastNWidgets(1));
      expect(find.byType(SliverToBoxAdapter), findsAtLeastNWidgets(3));
    });

    testWidgets('renders with custom dashboard stats', (tester) async {
      final customStats = DashboardStats(
        currentStreak: 7,
        todayLogged: false,
        weekStats: WeekStats(
          averageScore: 16.0,
          completedDays: 7,
          categoryAverages: {'Work': 4.0},
          dailyScores: [],
        ),
        monthlyTrend: {},
        topActivities: [],
        insights: [
          Insight(
            type: InsightType.suggestion,
            title: 'Log today',
            description: 'You haven\'t logged today yet.',
            icon: '📝',
          ),
        ],
      );

      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(dashboardStats: customStats),
        ),
      );
      await tester.pumpAndSettle();

      // Page renders without errors with custom stats
      expect(find.byType(NewDashboardPage), findsOneWidget);
    });

    testWidgets('renders LayoutBuilder for responsive layout', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const NewDashboardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // The page uses LayoutBuilder for responsive layout selection
      expect(find.byType(LayoutBuilder), findsAtLeastNWidgets(1));
    });
  });
}
