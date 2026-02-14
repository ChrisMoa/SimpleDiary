import 'dart:io';

import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and parses the test/.env file.
/// Returns null if the file doesn't exist.
Map<String, String>? _loadTestEnv() {
  final envFile = File('test/.env');
  if (!envFile.existsSync()) return null;

  final lines = envFile.readAsLinesSync();
  final env = <String, String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx < 0) continue;
    env[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
  }
  return env;
}

/// Returns a skip reason if the env is missing or still has placeholder values.
/// Returns null when the config is valid and tests should run.
String? _skipReason(Map<String, String>? env) {
  if (env == null) {
    return 'test/.env not found. '
        'Copy test/test_template.env to test/.env and fill in your Supabase credentials.';
  }

  final url = env['SUPABASE_URL'] ?? '';
  final key = env['SUPABASE_ANON_KEY'] ?? '';
  final email = env['SUPABASE_TEST_EMAIL'] ?? '';
  final password = env['SUPABASE_TEST_PASSWORD'] ?? '';

  final hasPlaceholders = url.contains('your-project') ||
      key.contains('your-anon-key') ||
      email == 'test@example.com' ||
      password == 'your-test-password';

  if (hasPlaceholders) {
    return 'test/.env still contains default placeholder credentials. '
        'Replace them with real Supabase test credentials to run these tests.';
  }

  if (url.isEmpty || key.isEmpty || email.isEmpty || password.isEmpty) {
    return 'test/.env is missing one or more required values '
        '(SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_TEST_EMAIL, SUPABASE_TEST_PASSWORD).';
  }

  return null;
}

/// Registers sync round-trip tests for a given API instance.
/// [label] is used in group names (e.g. "production" or "test").
/// [getApi] is a closure so the late-initialized API is only accessed at
/// test execution time, not during registration.
/// [noteId] and [templateId] are base IDs for upserted records.
void _defineSyncTests({
  required String label,
  required SupabaseApi Function() getApi,
  required String noteId,
  required String templateId,
  required Future<void> Function() ensureSignedIn,
}) {
  group('sync diary days ($label tables)', () {
    test('upload and fetch diary days round-trip', () async {
      await ensureSignedIn();
      final api = getApi();

      final testDay = DiaryDay(
        day: DateTime(2099, 1, 1),
        ratings: [
          DayRating(dayRating: DayRatings.social, score: 4),
          DayRating(dayRating: DayRatings.productivity, score: 3),
        ],
      );

      // Upload
      await api.syncDiaryDays([testDay], 'integration-test-user');

      // Fetch back
      final fetched = await api.fetchDiaryDays('integration-test-user');
      final match = fetched.where(
        (d) => d.day.year == 2099 && d.day.month == 1 && d.day.day == 1,
      );
      expect(match, isNotEmpty,
          reason: 'Uploaded diary day should be fetched back');

      final fetchedDay = match.first;
      expect(fetchedDay.ratings.length, testDay.ratings.length);
      expect(fetchedDay.ratings[0].score, 4);
      expect(fetchedDay.ratings[1].score, 3);
    });
  });

  group('sync notes ($label tables)', () {
    test('upload and fetch notes round-trip', () async {
      await ensureSignedIn();
      final api = getApi();

      final testNote = Note(
        id: noteId,
        title: 'Integration Test Note',
        description: 'Created by automated test',
        from: DateTime(2099, 6, 15, 9, 0),
        to: DateTime(2099, 6, 15, 10, 0),
        isAllDay: false,
        noteCategory: availableNoteCategories.first,
      );

      // Upload
      await api.syncNotes([testNote], 'integration-test-user');

      // Fetch back
      final fetched = await api.fetchNotes('integration-test-user');
      final match = fetched.where((n) => n.id == noteId);
      expect(match, isNotEmpty,
          reason: 'Uploaded note should be fetched back');

      final fetchedNote = match.first;
      expect(fetchedNote.title, 'Integration Test Note');
      expect(fetchedNote.description, 'Created by automated test');
      expect(fetchedNote.isAllDay, false);
      expect(fetchedNote.noteCategory.title,
          availableNoteCategories.first.title);
    });

    test('upload and fetch all-day note', () async {
      await ensureSignedIn();
      final api = getApi();

      final allDayNote = Note(
        id: '$noteId-allday',
        title: 'All Day Test',
        description: 'All day event',
        from: DateTime(2099, 7, 1),
        to: DateTime(2099, 7, 1),
        isAllDay: true,
        noteCategory: availableNoteCategories[1], // Freizeit
      );

      await api.syncNotes([allDayNote], 'integration-test-user');

      final fetched = await api.fetchNotes('integration-test-user');
      final match = fetched.where((n) => n.id == '$noteId-allday');
      expect(match, isNotEmpty);

      final fetchedNote = match.first;
      expect(fetchedNote.isAllDay, true);
      expect(fetchedNote.noteCategory.title, 'Freizeit');
    });
  });

  group('sync templates ($label tables)', () {
    test('upload and fetch templates round-trip', () async {
      await ensureSignedIn();
      final api = getApi();
      final prefix = label == 'test' ? 'test_' : '';

      final testTemplate = NoteTemplate(
        id: templateId,
        title: 'Integration Test Template',
        description: 'Test template description',
        durationMinutes: 45,
        noteCategory: availableNoteCategories[2], // Essen
      );

      // Upload — may fail if the note_templates table schema is outdated.
      try {
        await api.syncTemplates([testTemplate], 'integration-test-user');
      } catch (e) {
        if (e.toString().contains('description_sections')) {
          fail('Supabase ${prefix}note_templates table is missing the '
              '"description_sections" column. Run the migration from '
              'supabase.sql:\n'
              '  ALTER TABLE public.${prefix}note_templates\n'
              '    ADD COLUMN IF NOT EXISTS description_sections '
              "TEXT NOT NULL DEFAULT '';");
        }
        rethrow;
      }

      // Fetch back
      final fetched = await api.fetchTemplates('integration-test-user');
      final match = fetched.where((t) => t.id == templateId);
      expect(match, isNotEmpty,
          reason: 'Uploaded template should be fetched back');

      final fetchedTemplate = match.first;
      expect(fetchedTemplate.title, 'Integration Test Template');
      expect(fetchedTemplate.description, 'Test template description');
      expect(fetchedTemplate.durationMinutes, 45);
      expect(fetchedTemplate.noteCategory.title, 'Essen');
    });
  });

  group('full sync round-trip ($label tables)', () {
    test('upload diary days, notes, templates then fetch all back', () async {
      await ensureSignedIn();
      final api = getApi();
      final prefix = label == 'test' ? 'test_' : '';

      // Prepare test data
      final diaryDay = DiaryDay(
        day: DateTime(2099, 12, 31),
        ratings: [
          DayRating(dayRating: DayRatings.sport, score: 5),
        ],
      );

      final note = Note(
        id: '$noteId-full',
        title: 'Full Round-Trip Note',
        description: 'Full sync test',
        from: DateTime(2099, 12, 31, 14, 0),
        to: DateTime(2099, 12, 31, 15, 30),
        isAllDay: false,
        noteCategory: availableNoteCategories[3], // Gym
      );

      final template = NoteTemplate(
        id: '$templateId-full',
        title: 'Full Round-Trip Template',
        description: 'Full sync template',
        durationMinutes: 60,
        noteCategory: availableNoteCategories[4], // Schlafen
      );

      // Upload all
      await api.syncDiaryDays([diaryDay], 'integration-test-user');
      await api.syncNotes([note], 'integration-test-user');

      try {
        await api.syncTemplates([template], 'integration-test-user');
      } catch (e) {
        if (e.toString().contains('description_sections')) {
          fail('Supabase ${prefix}note_templates table is missing the '
              '"description_sections" column. Run the migration from '
              'supabase.sql:\n'
              '  ALTER TABLE public.${prefix}note_templates\n'
              '    ADD COLUMN IF NOT EXISTS description_sections '
              "TEXT NOT NULL DEFAULT '';");
        }
        rethrow;
      }

      // Fetch all back
      final fetchedDays = await api.fetchDiaryDays('integration-test-user');
      final fetchedNotes = await api.fetchNotes('integration-test-user');
      final fetchedTemplates =
          await api.fetchTemplates('integration-test-user');

      // Verify diary day
      final matchDay = fetchedDays.where(
        (d) => d.day.year == 2099 && d.day.month == 12 && d.day.day == 31,
      );
      expect(matchDay, isNotEmpty);
      expect(matchDay.first.ratings.first.score, 5);

      // Verify note
      final matchNote =
          fetchedNotes.where((n) => n.id == '$noteId-full');
      expect(matchNote, isNotEmpty);
      expect(matchNote.first.title, 'Full Round-Trip Note');

      // Verify template
      final matchTemplate =
          fetchedTemplates.where((t) => t.id == '$templateId-full');
      expect(matchTemplate, isNotEmpty);
      expect(matchTemplate.first.title, 'Full Round-Trip Template');
      expect(matchTemplate.first.noteCategory.title, 'Schlafen');
    });
  });
}

void main() {
  final env = _loadTestEnv();
  final skipReason = _skipReason(env);

  // These values are only accessed when skipReason == null, i.e. config is valid.
  late final String supabaseUrl;
  late final String supabaseAnonKey;
  late final String testEmail;
  late final String testPassword;

  if (skipReason == null) {
    supabaseUrl = env!['SUPABASE_URL']!;
    supabaseAnonKey = env['SUPABASE_ANON_KEY']!;
    testEmail = env['SUPABASE_TEST_EMAIL']!;
    testPassword = env['SUPABASE_TEST_PASSWORD']!;
  }

  group('Supabase integration', () {
    // Supabase is a singleton — initialize once and reuse across all tests.
    // Two API instances share the same client but target different tables.
    late SupabaseApi testApi;
    late SupabaseApi prodApi;

    /// Ensure the api is signed in before a test that needs auth.
    Future<void> ensureSignedIn() async {
      // Both APIs share the same Supabase client, so checking one is enough.
      if (!testApi.isSignedIn) {
        final ok =
            await testApi.signInWithEmailPassword(testEmail, testPassword);
        assert(ok, 'Could not sign in — check test/.env credentials');
      }
    }

    setUpAll(() async {
      // SharedPreferences must be mocked before Supabase.initialize()
      // because supabase_flutter stores the auth session there.
      SharedPreferences.setMockInitialValues({});

      testApi = SupabaseApi(tablePrefix: 'test_');
      await testApi.initialize(supabaseUrl, supabaseAnonKey);

      // Production API reuses the already-initialized Supabase singleton.
      prodApi = SupabaseApi();
      await prodApi.initialize(supabaseUrl, supabaseAnonKey);
    });

    // ------------------------------------------------------------------
    // Connection & authentication (table-independent, run once)
    // ------------------------------------------------------------------
    group('connection', () {
      test('sign in with valid credentials', () async {
        final success =
            await testApi.signInWithEmailPassword(testEmail, testPassword);
        expect(success, isTrue);
        expect(testApi.isSignedIn, isTrue);
        expect(testApi.currentUser, isNotNull);
      });

      test('sign in with wrong password returns false', () async {
        final success =
            await testApi.signInWithEmailPassword(testEmail, 'wrong-password-xyz');
        expect(success, isFalse);
      });

      test('sign out and sign back in', () async {
        await ensureSignedIn();
        expect(testApi.isSignedIn, isTrue);

        await testApi.signOut();
        expect(testApi.isSignedIn, isFalse);

        // Re-authenticate so subsequent tests keep working.
        final ok =
            await testApi.signInWithEmailPassword(testEmail, testPassword);
        expect(ok, isTrue);
      });
    });

    // ------------------------------------------------------------------
    // Sync tests — production tables (no prefix)
    // ------------------------------------------------------------------
    _defineSyncTests(
      label: 'production',
      getApi: () => prodApi,
      noteId: 'test-note-integration-prod-001',
      templateId: 'test-template-integration-prod-001',
      ensureSignedIn: ensureSignedIn,
    );

    // ------------------------------------------------------------------
    // Sync tests — test tables (test_ prefix)
    // ------------------------------------------------------------------
    _defineSyncTests(
      label: 'test',
      getApi: () => testApi,
      noteId: 'test-note-integration-test-001',
      templateId: 'test-template-integration-test-001',
      ensureSignedIn: ensureSignedIn,
    );

    // ------------------------------------------------------------------
    // Error handling — uses a separate SupabaseApi instance whose
    // internal _client is null (never initialized locally).
    // ------------------------------------------------------------------
    group('error handling', () {
      test('sign in on uninitialized api returns false', () async {
        // Create a fresh wrapper with _client = null.
        SupabaseApi.resetInitialization();
        final uninitApi = SupabaseApi(tablePrefix: 'test_');

        // signInWithEmailPassword catches the internal exception
        // and returns false when the client is not initialized.
        final result = await uninitApi.signInWithEmailPassword(
            testEmail, testPassword);
        expect(result, isFalse);

        // Restore shared state so later tests still work.
        await testApi.initialize(supabaseUrl, supabaseAnonKey);
      });

      test('sync without authentication throws', () async {
        await ensureSignedIn();
        await testApi.signOut();

        expect(
          () => testApi.syncDiaryDays([], 'user'),
          throwsException,
        );

        // Re-authenticate for any remaining tests.
        await testApi.signInWithEmailPassword(testEmail, testPassword);
      });

      test('fetch without authentication throws', () async {
        await ensureSignedIn();
        await testApi.signOut();

        expect(
          () => testApi.fetchNotes('user'),
          throwsException,
        );

        // Re-authenticate for any remaining tests.
        await testApi.signInWithEmailPassword(testEmail, testPassword);
      });
    });
  }, skip: skipReason);
}
