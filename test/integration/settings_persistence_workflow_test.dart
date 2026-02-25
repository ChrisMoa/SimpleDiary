import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  group('Settings Persistence Workflow', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Prevent GoogleFonts from fetching fonts over the network in tests
      GoogleFonts.config.allowRuntimeFetching = false;
      dotenv.testLoad(mergeWith: {'PROJECT_NAME': 'test_project'});
    });

    setUp(() {
      settingsContainer = SettingsContainer();
      settingsContainer.activeUserSettings = UserSettings.fromEmpty();
    });

    group('theme persistence across provider recreation', () {
      testWidgets('seed color change survives ThemeProvider recreation',
          (tester) async {
        // Session 1: change theme color
        final provider1 = ThemeProvider(settingsContainer);
        provider1.updateThemeFromSeedColor(Colors.blue);

        // Persist to settings (normally done by ThemeSettingsWidget)
        settingsContainer.activeUserSettings.themeSeedColor = Colors.blue;

        // Session 2: recreate provider (simulates app restart)
        final provider2 = ThemeProvider(settingsContainer);

        expect(provider2.seedColor, equals(Colors.blue));
      });

      testWidgets('dark mode toggle survives ThemeProvider recreation',
          (tester) async {
        // Session 1: enable dark mode
        final provider1 = ThemeProvider(settingsContainer);
        expect(provider1.state.brightness, Brightness.light);

        provider1.toggleDarkMode(true);
        expect(provider1.state.brightness, Brightness.dark);

        // Persist to settings
        settingsContainer.activeUserSettings.darkThemeMode = true;

        // Session 2: recreate
        final provider2 = ThemeProvider(settingsContainer);

        expect(provider2.state.brightness, Brightness.dark);
      });

      testWidgets('default seed color is used when no settings persisted',
          (tester) async {
        final provider = ThemeProvider(settingsContainer);

        expect(provider.seedColor, equals(defaultSeedColor));
      });
    });

    group('locale persistence across provider recreation', () {
      test('locale change persists to settingsContainer automatically', () {
        final provider = LocaleProvider(settingsContainer);

        provider.setLocale(const Locale('de'));

        // LocaleProvider auto-persists to settingsContainer
        expect(
          settingsContainer.activeUserSettings.languageCode,
          equals('de'),
        );
      });

      test('locale survives LocaleProvider recreation', () {
        // Session 1: change to German
        final provider1 = LocaleProvider(settingsContainer);
        provider1.setLocale(const Locale('de'));

        // Session 2: recreate (reads from settingsContainer)
        final provider2 = LocaleProvider(settingsContainer);

        expect(provider2.state, equals(const Locale('de')));
      });
    });

    group('combined settings workflow', () {
      testWidgets('theme + locale + dark mode all persist across restart',
          (tester) async {
        // Session 1: change multiple settings
        final theme1 = ThemeProvider(settingsContainer);
        final locale1 = LocaleProvider(settingsContainer);

        theme1.updateThemeFromSeedColor(Colors.deepPurple);
        theme1.toggleDarkMode(true);
        locale1.setLocale(const Locale('de'));

        // Persist theme (locale auto-persists)
        settingsContainer.activeUserSettings.themeSeedColor = Colors.deepPurple;
        settingsContainer.activeUserSettings.darkThemeMode = true;

        // Session 2: recreate all providers
        final theme2 = ThemeProvider(settingsContainer);
        final locale2 = LocaleProvider(settingsContainer);

        expect(theme2.seedColor, equals(Colors.deepPurple));
        expect(theme2.state.brightness, Brightness.dark);
        expect(locale2.state, equals(const Locale('de')));
      });

      testWidgets('different users have independent settings',
          (tester) async {
        // Set up user A
        settingsContainer.activeUserSettings.themeSeedColor = Colors.blue;
        settingsContainer.activeUserSettings.darkThemeMode = true;
        settingsContainer.activeUserSettings.languageCode = 'de';

        final themeA = ThemeProvider(settingsContainer);
        expect(themeA.seedColor, equals(Colors.blue));
        expect(themeA.state.brightness, Brightness.dark);

        // Switch to user B (fresh defaults)
        settingsContainer.activeUserSettings = UserSettings.fromEmpty();

        final themeB = ThemeProvider(settingsContainer);
        final localeB = LocaleProvider(settingsContainer);

        expect(themeB.seedColor, equals(defaultSeedColor));
        expect(themeB.state.brightness, Brightness.light);
        expect(localeB.state, equals(const Locale('en')));
      });

      testWidgets(
          'ThemeProvider does not auto-persist but LocaleProvider does',
          (tester) async {
        final theme = ThemeProvider(settingsContainer);
        final locale = LocaleProvider(settingsContainer);

        // ThemeProvider updates state but NOT settingsContainer
        theme.updateThemeFromSeedColor(Colors.red);
        expect(theme.seedColor, equals(Colors.red));
        // settingsContainer still has default
        expect(
          settingsContainer.activeUserSettings.themeSeedColor,
          equals(defaultSeedColor),
        );

        // LocaleProvider updates BOTH state and settingsContainer
        locale.setLocale(const Locale('de'));
        expect(locale.state, equals(const Locale('de')));
        expect(
          settingsContainer.activeUserSettings.languageCode,
          equals('de'),
        );
      });
    });
  });
}
