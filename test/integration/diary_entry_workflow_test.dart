import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/integration_test_fixtures.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() => initTestSettingsContainer());

  group('Diary Entry Workflow', () {
    group('provider chain: ratings -> diary day -> persistence', () {
      test('DayRatingsNotifier updates propagate correctly', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(dayRatingsProvider.notifier);

        // Default: all ratings at score 3
        final initial = container.read(dayRatingsProvider);
        expect(initial, hasLength(4));
        expect(initial.every((r) => r.score == 3), isTrue);

        // Update each rating
        notifier.updateRating(DayRatings.social, 5);
        notifier.updateRating(DayRatings.productivity, 2);
        notifier.updateRating(DayRatings.sport, 4);
        notifier.updateRating(DayRatings.food, 1);

        final updated = container.read(dayRatingsProvider);
        expect(
          updated.firstWhere((r) => r.dayRating == DayRatings.social).score,
          5,
        );
        expect(
          updated.firstWhere((r) => r.dayRating == DayRatings.productivity).score,
          2,
        );
        expect(
          updated.firstWhere((r) => r.dayRating == DayRatings.sport).score,
          4,
        );
        expect(
          updated.firstWhere((r) => r.dayRating == DayRatings.food).score,
          1,
        );
      });

      test('constructing DiaryDay from ratings and saving to provider', () async {
        final container = ProviderContainer(overrides: [
          diaryDayLocalDbDataProvider.overrideWith(
            (_) => TestDbRepository<DiaryDay>(
              tableName: DiaryDay.tableName,
              columns: DiaryDay.columns,
              fromMap: DiaryDay.fromDbMap,
            ),
          ),
        ]);
        addTearDown(container.dispose);

        // Build ratings
        final ratingsNotifier = container.read(dayRatingsProvider.notifier);
        ratingsNotifier.updateRating(DayRatings.social, 5);
        ratingsNotifier.updateRating(DayRatings.productivity, 4);
        ratingsNotifier.updateRating(DayRatings.sport, 3);
        ratingsNotifier.updateRating(DayRatings.food, 4);

        // Construct and save diary day (mirrors _saveLegacyDay logic)
        final ratings = container.read(dayRatingsProvider);
        final diaryDay = DiaryDay(
          day: DateTime(2026, 2, 20),
          ratings: ratings,
        );

        await container
            .read(diaryDayLocalDbDataProvider.notifier)
            .addElement(diaryDay);

        // Verify persistence
        final saved = container.read(diaryDayLocalDbDataProvider);
        expect(saved, hasLength(1));
        expect(saved.first.overallScore, 5 + 4 + 3 + 4);
      });

      test('diaryDayFullDataProvider associates notes with diary days', () async {
        final today = DateTime(2026, 2, 20);
        final testNotes = [
          makeTestNote(
            title: 'Morning',
            from: DateTime(2026, 2, 20, 9, 0),
          ),
          makeTestNote(
            title: 'Evening',
            from: DateTime(2026, 2, 20, 18, 0),
          ),
          // Note on a different day — should not be associated
          makeTestNote(
            title: 'Yesterday',
            from: DateTime(2026, 2, 19, 12, 0),
          ),
        ];
        final diaryDay = DiaryDay(day: today, ratings: defaultRatings);

        final container = ProviderContainer(overrides: [
          diaryDayLocalDbDataProvider.overrideWith(
            (_) => TestDbRepository<DiaryDay>(
              tableName: DiaryDay.tableName,
              columns: DiaryDay.columns,
              fromMap: DiaryDay.fromDbMap,
              initialData: [diaryDay],
            ),
          ),
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
              initialData: testNotes,
            ),
          ),
        ]);
        addTearDown(container.dispose);

        final fullDays = container.read(diaryDayFullDataProvider);

        expect(fullDays, hasLength(1));
        expect(fullDays.first.notes, hasLength(2));
        expect(
          fullDays.first.notes.map((n) => n.title),
          containsAll(['Morning', 'Evening']),
        );
      });

      test('isDiaryOfDayCompleteProvider returns true after saving all ratings',
          () async {
        final today = DateTime(2026, 2, 20);
        final diaryDay = DiaryDay(day: today, ratings: defaultRatings);

        final container = ProviderContainer(overrides: [
          diaryDayLocalDbDataProvider.overrideWith(
            (_) => TestDbRepository<DiaryDay>(
              tableName: DiaryDay.tableName,
              columns: DiaryDay.columns,
              fromMap: DiaryDay.fromDbMap,
              initialData: [diaryDay],
            ),
          ),
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        // Set selected date to today so isDiaryOfDayCompleteProvider evaluates
        container
            .read(noteSelectedDateProvider.notifier)
            .updateSelectedDate(today);

        // Allow microtasks to settle
        await Future<void>.delayed(Duration.zero);

        final isComplete = container.read(isDiaryOfDayCompleteProvider);
        expect(isComplete, isTrue);
      });

      test('isDiaryOfDayCompleteProvider returns false with no diary day', () {
        final container = ProviderContainer(overrides: [
          diaryDayLocalDbDataProvider.overrideWith(
            (_) => TestDbRepository<DiaryDay>(
              tableName: DiaryDay.tableName,
              columns: DiaryDay.columns,
              fromMap: DiaryDay.fromDbMap,
            ),
          ),
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        final isComplete = container.read(isDiaryOfDayCompleteProvider);
        expect(isComplete, isFalse);
      });
    });

    group('wizard note providers integration', () {
      test('wizardDayNotesProvider filters notes to selected date', () {
        final testNotes = [
          makeTestNote(
            title: 'Today Note',
            from: DateTime(2026, 2, 20, 9, 0),
          ),
          makeTestNote(
            title: 'Tomorrow Note',
            from: DateTime(2026, 2, 21, 9, 0),
          ),
        ];

        final container = ProviderContainer(overrides: [
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
              initialData: testNotes,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        // Set wizard date to Feb 20
        container
            .read(wizardSelectedDateProvider.notifier)
            .updateSelectedDate(DateTime(2026, 2, 20));

        final wizardNotes = container.read(wizardDayNotesProvider);
        expect(wizardNotes, hasLength(1));
        expect(wizardNotes.first.title, 'Today Note');
      });

      test('adding note to provider updates wizardDayNotesProvider', () async {
        final container = ProviderContainer(overrides: [
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        // Set wizard date
        container
            .read(wizardSelectedDateProvider.notifier)
            .updateSelectedDate(DateTime(2026, 2, 20));

        expect(container.read(wizardDayNotesProvider), isEmpty);

        // Add a note for that date
        await container.read(notesLocalDataProvider.notifier).addElement(
              makeTestNote(
                title: 'New Note',
                from: DateTime(2026, 2, 20, 10, 0),
              ),
            );

        expect(container.read(wizardDayNotesProvider), hasLength(1));
      });

      test('createEmptyNoteProvider uses default category and next time slot',
          () {
        final container = ProviderContainer(overrides: [
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        container
            .read(wizardSelectedDateProvider.notifier)
            .updateSelectedDate(DateTime(2026, 2, 20));

        final emptyNote = container.read(createEmptyNoteProvider);

        // Should have an empty title
        expect(emptyNote.title, isEmpty);
        // Should use default category (first in list)
        expect(emptyNote.noteCategory.title, 'Work');
        // Should start at 7:00 (day start, since no notes exist)
        expect(emptyNote.from.hour, 7);
        expect(emptyNote.from.minute, 0);
        // Duration should be 30 minutes
        expect(
          emptyNote.to.difference(emptyNote.from).inMinutes,
          30,
        );
      });
    });

    group('enhanced day rating provider integration', () {
      test('enhanced rating resets when wizard date changes', () {
        final container = ProviderContainer(overrides: [
          diaryDayLocalDbDataProvider.overrideWith(
            (_) => TestDbRepository<DiaryDay>(
              tableName: DiaryDay.tableName,
              columns: DiaryDay.columns,
              fromMap: DiaryDay.fromDbMap,
            ),
          ),
          notesLocalDataProvider.overrideWith(
            (_) => TestDbRepository<Note>(
              tableName: Note.tableName,
              columns: Note.columns,
              fromMap: Note.fromDbMap,
            ),
          ),
          categoryLocalDataProvider.overrideWith(
            (_) => TestCategoryProvider(integrationTestCategories),
          ),
        ]);
        addTearDown(container.dispose);

        // Set date and modify enhanced rating
        container
            .read(wizardSelectedDateProvider.notifier)
            .updateSelectedDate(DateTime(2026, 2, 20));

        container.read(enhancedDayRatingProvider.notifier).updateWellbeing(
              const WellbeingRating(mood: 4, energy: 3),
            );

        expect(
          container.read(enhancedDayRatingProvider).wellbeing.mood,
          4,
        );

        // Change date — enhanced rating should reset
        container
            .read(wizardSelectedDateProvider.notifier)
            .updateSelectedDate(DateTime(2026, 2, 21));

        expect(
          container.read(enhancedDayRatingProvider).wellbeing.mood,
          0,
        );
      });
    });
  });
}
