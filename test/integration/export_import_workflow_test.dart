import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/integration_test_fixtures.dart';

void main() {
  late FileDbProvider provider;
  late Directory tempDir;

  setUp(() {
    provider = FileDbProvider();
    tempDir = Directory.systemTemp.createTempSync('integration_export_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Export/Import Workflow', () {
    group('full data round-trip with notes', () {
      test('diary days with embedded notes survive export/import', () {
        final notes = [
          makeTestNote(
            title: 'Morning Standup',
            from: DateTime(2026, 2, 20, 9, 0),
            category: workCategory,
          ),
          makeTestNote(
            title: 'Lunch',
            from: DateTime(2026, 2, 20, 12, 0),
            category: foodCategory,
          ),
        ];
        final diaryDay = makeTestDiaryDay(
          day: DateTime(2026, 2, 20),
          notes: notes,
        );

        final exported = provider.exportToString(
          diaryDays: [diaryDay],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);

        expect(imported.data, hasLength(1));
        expect(imported.data.first.notes, hasLength(2));
        expect(imported.data.first.notes[0].title, 'Morning Standup');
        expect(imported.data.first.notes[1].title, 'Lunch');
      });

      test('multiple diary days with mixed content round-trip', () {
        final dayWithNotes = makeTestDiaryDay(
          day: DateTime(2026, 2, 20),
          notes: [
            makeTestNote(title: 'Note A', from: DateTime(2026, 2, 20, 9, 0)),
            makeTestNote(title: 'Note B', from: DateTime(2026, 2, 20, 14, 0)),
          ],
        );
        final dayWithoutNotes = makeTestDiaryDay(
          day: DateTime(2026, 2, 21),
          notes: [],
        );
        final dayWithManyNotes = makeTestDiaryDay(
          day: DateTime(2026, 2, 22),
          notes: List.generate(
            5,
            (i) => makeTestNote(
              title: 'Note $i',
              from: DateTime(2026, 2, 22, 8 + i, 0),
            ),
          ),
        );

        final exported = provider.exportToString(
          diaryDays: [dayWithNotes, dayWithoutNotes, dayWithManyNotes],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);

        expect(imported.data, hasLength(3));
        expect(imported.data[0].notes, hasLength(2));
        expect(imported.data[1].notes, isEmpty);
        expect(imported.data[2].notes, hasLength(5));
      });

      test('file-based export and import round-trip with notes', () async {
        final file = File('${tempDir.path}/notes_roundtrip.json');
        final notes = [
          makeTestNote(
            title: 'Important Meeting',
            description: 'Discuss project roadmap',
            from: DateTime(2026, 2, 20, 10, 0),
          ),
        ];
        final diaryDays = [makeTestDiaryDay(day: DateTime(2026, 2, 20), notes: notes)];

        await provider.exportWithMetadata(
          diaryDays: diaryDays,
          file: file,
          username: 'test_user',
          encrypted: false,
        );

        // Import into a fresh provider
        final importProvider = FileDbProvider();
        final metadata = await importProvider.import(file);

        expect(metadata, isNotNull);
        expect(metadata!.encrypted, false);
        expect(metadata.username, 'test_user');
        expect(importProvider.state, hasLength(1));
        expect(importProvider.state.first.notes, hasLength(1));
        expect(importProvider.state.first.notes.first.title, 'Important Meeting');
      });

      test('encrypted round-trip preserves notes', () async {
        const password = 'securePassword123';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final file = File('${tempDir.path}/encrypted_notes.json');

        final notes = [
          makeTestNote(title: 'Secret Note', from: DateTime(2026, 2, 20, 9, 0)),
        ];
        final diaryDays = [makeTestDiaryDay(day: DateTime(2026, 2, 20), notes: notes)];

        await provider.exportWithMetadata(
          diaryDays: diaryDays,
          file: file,
          username: 'secure_user',
          salt: salt,
          encrypted: true,
          password: password,
        );

        final importProvider = FileDbProvider();
        final metadata =
            await importProvider.import(file, password: password);

        expect(metadata!.encrypted, true);
        expect(importProvider.state, hasLength(1));
        expect(importProvider.state.first.notes, hasLength(1));
        expect(importProvider.state.first.notes.first.title, 'Secret Note');
      });

      test('import populates provider state for downstream use', () async {
        final file = File('${tempDir.path}/state_test.json');
        final diaryDays = [
          makeTestDiaryDay(
            day: DateTime(2026, 2, 20),
            notes: [
              makeTestNote(title: 'Work', from: DateTime(2026, 2, 20, 9, 0)),
            ],
          ),
          makeTestDiaryDay(
            day: DateTime(2026, 2, 21),
            notes: [
              makeTestNote(title: 'Play', from: DateTime(2026, 2, 21, 15, 0)),
            ],
          ),
        ];

        await provider.exportWithMetadata(
          diaryDays: diaryDays,
          file: file,
          encrypted: false,
        );

        final importProvider = FileDbProvider();
        await importProvider.import(file);

        // State should be directly usable
        expect(importProvider.state, hasLength(2));
        final allNotes = importProvider.state.expand((d) => d.notes).toList();
        expect(allNotes, hasLength(2));
        expect(allNotes.map((n) => n.title), containsAll(['Work', 'Play']));
      });
    });

    group('cross-feature data integrity', () {
      test('note categories are preserved through export/import', () {
        final diaryDay = makeTestDiaryDay(
          day: DateTime(2026, 2, 20),
          notes: [
            makeTestNote(
              title: 'Work Task',
              from: DateTime(2026, 2, 20, 9, 0),
              category: workCategory,
            ),
            makeTestNote(
              title: 'Lunch',
              from: DateTime(2026, 2, 20, 12, 0),
              category: foodCategory,
            ),
          ],
        );

        final exported = provider.exportToString(
          diaryDays: [diaryDay],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);
        final importedNotes = imported.data.first.notes;

        expect(importedNotes[0].noteCategory.title, 'Work');
        expect(importedNotes[1].noteCategory.title, 'Food');
      });

      test('all 4 DayRating types survive round-trip', () {
        final diaryDay = makeTestDiaryDay(
          day: DateTime(2026, 2, 20),
          ratings: [
            DayRating(dayRating: DayRatings.social, score: 5),
            DayRating(dayRating: DayRatings.productivity, score: 2),
            DayRating(dayRating: DayRatings.sport, score: 4),
            DayRating(dayRating: DayRatings.food, score: 3),
          ],
        );

        final exported = provider.exportToString(
          diaryDays: [diaryDay],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);
        final ratings = imported.data.first.ratings;

        expect(ratings, hasLength(4));
        expect(ratings.firstWhere((r) => r.dayRating == DayRatings.social).score, 5);
        expect(ratings.firstWhere((r) => r.dayRating == DayRatings.productivity).score, 2);
        expect(ratings.firstWhere((r) => r.dayRating == DayRatings.sport).score, 4);
        expect(ratings.firstWhere((r) => r.dayRating == DayRatings.food).score, 3);
      });

      test('enhanced day rating survives export/import round-trip', () {
        final enhanced = EnhancedDayRating(
          date: DateTime(2026, 2, 20),
          quickMood: MoodPosition(
            valence: 0.7,
            arousal: 0.5,
            timestamp: DateTime(2026, 2, 20, 8, 0),
          ),
          wellbeing: const WellbeingRating(
            mood: 4,
            energy: 3,
            connection: 5,
            purpose: 4,
            achievement: 3,
            engagement: 4,
          ),
          emotions: const [],
          context: ContextualFactors.empty(),
        );

        final diaryDay = makeTestDiaryDay(
          day: DateTime(2026, 2, 20),
          enhancedRating: enhanced,
        );

        final exported = provider.exportToString(
          diaryDays: [diaryDay],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);
        final importedRating = imported.data.first.enhancedRating;

        expect(importedRating, isNotNull);
        expect(importedRating!.quickMood!.valence, closeTo(0.7, 0.001));
        expect(importedRating.quickMood!.arousal, closeTo(0.5, 0.001));
        expect(importedRating.wellbeing.mood, 4);
        expect(importedRating.wellbeing.connection, 5);
      });

      test('empty data exports and imports cleanly', () {
        final exported = provider.exportToString(
          diaryDays: [],
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);
        expect(imported.data, isEmpty);
      });

      test('large dataset round-trip (30 days with notes)', () {
        final diaryDays = List.generate(30, (i) {
          final day = dateAt(i);
          return makeTestDiaryDay(
            day: day,
            notes: List.generate(
              3,
              (j) => makeTestNote(
                title: 'Note $j on day $i',
                from: DateTime(day.year, day.month, day.day, 8 + j, 0),
              ),
            ),
          );
        });

        final exported = provider.exportToString(
          diaryDays: diaryDays,
          encrypted: false,
        );

        final imported = ExportData.fromJson(exported);

        expect(imported.data, hasLength(30));
        // Spot-check
        expect(imported.data.first.notes, hasLength(3));
        expect(imported.data.last.notes, hasLength(3));
        expect(imported.data[15].notes.first.title, 'Note 0 on day 15');
      });
    });
  });
}
