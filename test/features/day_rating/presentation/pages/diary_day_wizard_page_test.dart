import 'package:day_tracker/features/day_rating/presentation/pages/diary_day_wizard_page.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/diary_day_editing_wizard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestSettingsContainer();
    SharedPreferences.setMockInitialValues({});
  });

  group('DiaryDayWizardPage', () {
    testWidgets('shows shimmer loading placeholders initially', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );

      // First frame — the widget should exist and be loading
      expect(find.byType(DiaryDayWizardPage), findsOneWidget);
      // The wizard widget should NOT be visible yet (still loading)
      expect(find.byType(DiaryDayEditingWizardWidget), findsNothing);
    });

    testWidgets('transitions from loading to wizard widget', (tester) async {
      // Use a larger surface to avoid overflow errors in child widgets
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DiaryDayEditingWizardWidget), findsOneWidget);
    });

    testWidgets('shows tab navigation with Calendar, Note Details, Day Rating',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // The wizard widget uses DefaultTabController with 3 tabs
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Note Details'), findsOneWidget);
      expect(find.text('Day Rating'), findsOneWidget);
    });

    testWidgets('renders tab icons for each section', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.edit_note), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.rate_review_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('wraps content in SafeArea after loading', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // Both the page and the wizard widget wrap in SafeArea
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('tab navigation switches between views', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestApp(
          const DiaryDayWizardPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Note Details" tab
      await tester.tap(find.text('Note Details'));
      await tester.pumpAndSettle();

      // Tap on "Day Rating" tab
      await tester.tap(find.text('Day Rating'));
      await tester.pumpAndSettle();

      // TabBar should remain visible throughout navigation
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
