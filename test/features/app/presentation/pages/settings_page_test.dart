import 'package:day_tracker/features/app/presentation/pages/settings_page.dart';
import 'package:day_tracker/features/app/presentation/widgets/backup_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/biometric_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/language_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/notification_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/supabase_settings_widget.dart';
import 'package:day_tracker/features/app/presentation/widgets/theme_settings_widget.dart';
import 'package:day_tracker/core/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestSettingsContainer();
  });

  group('SettingsPage', () {
    // Use a tall surface so SliverList builds all settings sections.
    void setTallSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
    }

    void resetSurface(WidgetTester tester) {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }

    testWidgets('renders settings title', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders top settings sections (theme, language)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // These are at the top and always visible
      expect(find.byType(ThemeSettingsWidget), findsOneWidget);
      expect(find.byType(LanguageSettingsWidget), findsOneWidget);
    });

    testWidgets('renders all settings sections with tall surface',
        (tester) async {
      setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ThemeSettingsWidget), findsOneWidget);
      expect(find.byType(LanguageSettingsWidget), findsOneWidget);
      expect(find.byType(NotificationSettingsWidget), findsOneWidget);
      expect(find.byType(BiometricSettingsWidget), findsOneWidget);
      expect(find.byType(BackupSettingsWidget), findsOneWidget);
      expect(find.byType(SupabaseSettingsWidget), findsOneWidget);
    });

    testWidgets('renders category management section with tall surface',
        (tester) async {
      setTallSurface(tester);
      addTearDown(() => resetSurface(tester));

      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // l10n English: "Manage Categories"
      expect(find.text('Manage Categories'), findsOneWidget);
      // Chevron icon for navigation
      expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(1));
    });

    testWidgets('renders multiple SettingsSection components', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // At least the visible sections have SettingsSection wrappers
      expect(find.byType(SettingsSection), findsAtLeastNWidgets(2));
    });

    testWidgets('settings page uses CustomScrollView', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const SettingsPage(),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
