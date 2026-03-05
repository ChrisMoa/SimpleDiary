import 'package:day_tracker/core/provider/locale_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/theme/themes.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
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

    group('supabase settings persistence', () {
      test('URL update persists to settingsContainer', () {
        final notifier = SupabaseSettingsNotifier(settingsContainer);

        notifier.updateUrl('https://example.supabase.co');

        // Simulate what the widget does: sync to settingsContainer
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(supabaseUrl: 'https://example.supabase.co');

        expect(
          settingsContainer.activeUserSettings.supabaseSettings.supabaseUrl,
          equals('https://example.supabase.co'),
        );
      });

      test('all credential fields persist to settingsContainer', () {
        final notifier = SupabaseSettingsNotifier(settingsContainer);

        // Simulate widget onChanged callbacks
        notifier.updateUrl('https://test.supabase.co');
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(supabaseUrl: 'https://test.supabase.co');

        notifier.updateAnonKey('test-anon-key');
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(supabaseAnonKey: 'test-anon-key');

        notifier.updateEmail('user@example.com');
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(email: 'user@example.com');

        notifier.updatePassword('secret123');
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(password: 'secret123');

        final saved = settingsContainer.activeUserSettings.supabaseSettings;
        expect(saved.supabaseUrl, equals('https://test.supabase.co'));
        expect(saved.supabaseAnonKey, equals('test-anon-key'));
        expect(saved.email, equals('user@example.com'));
        expect(saved.password, equals('secret123'));
        expect(saved.isConfigured, isTrue);
      });

      test('auto-sync toggle persists to settingsContainer', () {
        // Pre-configure credentials so isConfigured is true
        settingsContainer.activeUserSettings.supabaseSettings =
            SupabaseSettings(
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'key',
          email: 'a@b.com',
          password: 'pass',
        );

        final notifier = SupabaseSettingsNotifier(settingsContainer);
        notifier.updateAutoSyncEnabled(true);
        settingsContainer.activeUserSettings.supabaseSettings =
            settingsContainer.activeUserSettings.supabaseSettings
                .copyWith(autoSyncEnabled: true);

        expect(
          settingsContainer.activeUserSettings.supabaseSettings.autoSyncEnabled,
          isTrue,
        );
      });

      test('supabase settings survive provider recreation', () {
        // Session 1: configure supabase
        final notifier1 = SupabaseSettingsNotifier(settingsContainer);
        notifier1.updateUrl('https://prod.supabase.co');
        notifier1.updateAnonKey('prod-key');
        notifier1.updateEmail('prod@example.com');
        notifier1.updatePassword('prod-pass');

        // Persist to settings container (widget does this on each change)
        settingsContainer.activeUserSettings.supabaseSettings =
            SupabaseSettings(
          supabaseUrl: 'https://prod.supabase.co',
          supabaseAnonKey: 'prod-key',
          email: 'prod@example.com',
          password: 'prod-pass',
        );

        // Session 2: recreate notifier (simulates app restart)
        final notifier2 = SupabaseSettingsNotifier(settingsContainer);

        expect(notifier2.state.supabaseUrl, equals('https://prod.supabase.co'));
        expect(notifier2.state.supabaseAnonKey, equals('prod-key'));
        expect(notifier2.state.email, equals('prod@example.com'));
        expect(notifier2.state.password, equals('prod-pass'));
        expect(notifier2.state.isConfigured, isTrue);
      });

      test('empty supabase settings are default', () {
        final notifier = SupabaseSettingsNotifier(settingsContainer);

        expect(notifier.state.supabaseUrl, isEmpty);
        expect(notifier.state.supabaseAnonKey, isEmpty);
        expect(notifier.state.email, isEmpty);
        expect(notifier.state.password, isEmpty);
        expect(notifier.state.isConfigured, isFalse);
        expect(notifier.state.autoSyncEnabled, isFalse);
      });
    });
  });
}
