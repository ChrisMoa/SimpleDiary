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
    late SupabaseApi api;

    // Use fixed IDs so repeated test runs upsert rather than creating duplicates.
    const testNoteId = 'test-note-integration-001';
    const testTemplateId = 'test-template-integration-001';

    /// Ensure the api is signed in before a test that needs auth.
    Future<void> ensureSignedIn() async {
      if (!api.isSignedIn) {
        final ok =
            await api.signInWithEmailPassword(testEmail, testPassword);
        assert(ok, 'Could not sign in — check test/.env credentials');
      }
    }

    setUpAll(() async {
      // SharedPreferences must be mocked before Supabase.initialize()
      // because supabase_flutter stores the auth session there.
      SharedPreferences.setMockInitialValues({});

      api = SupabaseApi(tablePrefix: 'test_');
      await api.initialize(supabaseUrl, supabaseAnonKey);
    });

    // ------------------------------------------------------------------
    // Connection & authentication
    // ------------------------------------------------------------------
    group('connection', () {
      test('sign in with valid credentials', () async {
        final success =
            await api.signInWithEmailPassword(testEmail, testPassword);
        expect(success, isTrue);
        expect(api.isSignedIn, isTrue);
        expect(api.currentUser, isNotNull);
      });

      test('sign in with wrong password returns false', () async {
        final success =
            await api.signInWithEmailPassword(testEmail, 'wrong-password-xyz');
        expect(success, isFalse);
      });

      test('sign out and sign back in', () async {
        await ensureSignedIn();
        expect(api.isSignedIn, isTrue);

        await api.signOut();
        expect(api.isSignedIn, isFalse);

        // Re-authenticate so subsequent tests keep working.
        final ok =
            await api.signInWithEmailPassword(testEmail, testPassword);
        expect(ok, isTrue);
      });
    });

    // ------------------------------------------------------------------
    // Sync diary days
    // ------------------------------------------------------------------
    group('sync diary days', () {
      test('upload and fetch diary days round-trip', () async {
        await ensureSignedIn();

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

    // ------------------------------------------------------------------
    // Sync notes
    // ------------------------------------------------------------------
    group('sync notes', () {
      test('upload and fetch notes round-trip', () async {
        await ensureSignedIn();

        final testNote = Note(
          id: testNoteId,
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
        final match = fetched.where((n) => n.id == testNoteId);
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

        final allDayNote = Note(
          id: '$testNoteId-allday',
          title: 'All Day Test',
          description: 'All day event',
          from: DateTime(2099, 7, 1),
          to: DateTime(2099, 7, 1),
          isAllDay: true,
          noteCategory: availableNoteCategories[1], // Freizeit
        );

        await api.syncNotes([allDayNote], 'integration-test-user');

        final fetched = await api.fetchNotes('integration-test-user');
        final match = fetched.where((n) => n.id == '$testNoteId-allday');
        expect(match, isNotEmpty);

        final fetchedNote = match.first;
        expect(fetchedNote.isAllDay, true);
        expect(fetchedNote.noteCategory.title, 'Freizeit');
      });
    });

    // ------------------------------------------------------------------
    // Sync templates
    // ------------------------------------------------------------------
    group('sync templates', () {
      test('upload and fetch templates round-trip', () async {
        await ensureSignedIn();

        final testTemplate = NoteTemplate(
          id: testTemplateId,
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
            fail('Supabase note_templates table is missing the '
                '"description_sections" column. Run the migration from '
                'supabase.sql:\n'
                '  ALTER TABLE public.note_templates\n'
                '    ADD COLUMN IF NOT EXISTS description_sections '
                "TEXT NOT NULL DEFAULT '';");
          }
          rethrow;
        }

        // Fetch back
        final fetched = await api.fetchTemplates('integration-test-user');
        final match = fetched.where((t) => t.id == testTemplateId);
        expect(match, isNotEmpty,
            reason: 'Uploaded template should be fetched back');

        final fetchedTemplate = match.first;
        expect(fetchedTemplate.title, 'Integration Test Template');
        expect(fetchedTemplate.description, 'Test template description');
        expect(fetchedTemplate.durationMinutes, 45);
        expect(fetchedTemplate.noteCategory.title, 'Essen');
      });
    });

    // ------------------------------------------------------------------
    // Full round-trip: upload everything then download
    // ------------------------------------------------------------------
    group('full sync round-trip', () {
      test('upload diary days, notes, templates then fetch all back', () async {
        await ensureSignedIn();

        // Prepare test data
        final diaryDay = DiaryDay(
          day: DateTime(2099, 12, 31),
          ratings: [
            DayRating(dayRating: DayRatings.sport, score: 5),
          ],
        );

        final note = Note(
          id: '$testNoteId-full',
          title: 'Full Round-Trip Note',
          description: 'Full sync test',
          from: DateTime(2099, 12, 31, 14, 0),
          to: DateTime(2099, 12, 31, 15, 30),
          isAllDay: false,
          noteCategory: availableNoteCategories[3], // Gym
        );

        final template = NoteTemplate(
          id: '$testTemplateId-full',
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
            fail('Supabase note_templates table is missing the '
                '"description_sections" column. Run the migration from '
                'supabase.sql:\n'
                '  ALTER TABLE public.note_templates\n'
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
            fetchedNotes.where((n) => n.id == '$testNoteId-full');
        expect(matchNote, isNotEmpty);
        expect(matchNote.first.title, 'Full Round-Trip Note');

        // Verify template
        final matchTemplate =
            fetchedTemplates.where((t) => t.id == '$testTemplateId-full');
        expect(matchTemplate, isNotEmpty);
        expect(matchTemplate.first.title, 'Full Round-Trip Template');
        expect(matchTemplate.first.noteCategory.title, 'Schlafen');
      });
    });

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
        await api.initialize(supabaseUrl, supabaseAnonKey);
      });

      test('sync without authentication throws', () async {
        await ensureSignedIn();
        await api.signOut();

        expect(
          () => api.syncDiaryDays([], 'user'),
          throwsException,
        );

        // Re-authenticate for any remaining tests.
        await api.signInWithEmailPassword(testEmail, testPassword);
      });

      test('fetch without authentication throws', () async {
        await ensureSignedIn();
        await api.signOut();

        expect(
          () => api.fetchNotes('user'),
          throwsException,
        );

        // Re-authenticate for any remaining tests.
        await api.signInWithEmailPassword(testEmail, testPassword);
      });
    });
  }, skip: skipReason);
}
