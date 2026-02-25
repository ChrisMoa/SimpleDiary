import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/integration_test_fixtures.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() => initTestSettingsContainer());

  group('Note Search Workflow', () {
    // Shared test data
    final testNotes = [
      makeTestNote(
        id: 'n1',
        title: 'Morning Standup',
        description: 'Daily team sync',
        from: DateTime(2026, 2, 20, 9, 0),
        category: workCategory,
      ),
      makeTestNote(
        id: 'n2',
        title: 'Lunch Break',
        description: 'Pasta at Italian place',
        from: DateTime(2026, 2, 20, 12, 0),
        category: foodCategory,
      ),
      makeTestNote(
        id: 'n3',
        title: 'Code Review',
        description: 'PR #42 review session',
        from: DateTime(2026, 2, 21, 14, 0),
        category: workCategory,
      ),
      makeTestNote(
        id: 'n4',
        title: 'Dinner',
        description: 'Cooked pasta at home',
        from: DateTime(2026, 2, 21, 19, 0),
        category: foodCategory,
      ),
    ];

    ProviderContainer createContainer({List<Note>? notes}) {
      return ProviderContainer(overrides: [
        notesLocalDataProvider.overrideWith(
          (_) => TestDbRepository<Note>(
            tableName: Note.tableName,
            columns: Note.columns,
            fromMap: Note.fromDbMap,
            initialData: notes ?? testNotes,
          ),
        ),
        categoryLocalDataProvider
            .overrideWith((_) => TestCategoryProvider(integrationTestCategories)),
      ]);
    }

    group('full provider chain: add note -> search -> filter', () {
      test('notes added to provider appear in filteredNotesProvider', () async {
        final container = createContainer(notes: []);
        addTearDown(container.dispose);

        // Initially empty
        expect(container.read(filteredNotesProvider), isEmpty);

        // Add notes one by one
        final notifier = container.read(notesLocalDataProvider.notifier);
        await notifier.addElement(testNotes[0]);
        expect(container.read(filteredNotesProvider), hasLength(1));

        await notifier.addElement(testNotes[1]);
        expect(container.read(filteredNotesProvider), hasLength(2));
      });

      test('setting search query filters results in real-time', () {
        final container = createContainer();
        addTearDown(container.dispose);

        // All notes present initially
        expect(container.read(filteredNotesProvider), hasLength(4));

        // Search for "pasta" — should match Lunch Break + Dinner
        container.read(noteSearchProvider.notifier).setQuery('pasta');
        final results = container.read(filteredNotesProvider);

        expect(results, hasLength(2));
        expect(results.map((n) => n.title), containsAll(['Lunch Break', 'Dinner']));
      });

      test('category filter narrows results', () {
        final container = createContainer();
        addTearDown(container.dispose);

        container
            .read(noteSearchProvider.notifier)
            .setCategoryFilter(workCategory);
        final results = container.read(filteredNotesProvider);

        expect(results, hasLength(2));
        expect(
          results.every((n) => n.noteCategory.title == 'Work'),
          isTrue,
        );
      });

      test('combined category + text search narrows results further', () {
        final container = createContainer();
        addTearDown(container.dispose);

        final searchNotifier = container.read(noteSearchProvider.notifier);
        searchNotifier.setCategoryFilter(workCategory);
        searchNotifier.setQuery('standup');

        final results = container.read(filteredNotesProvider);

        expect(results, hasLength(1));
        expect(results.first.title, 'Morning Standup');
      });

      test('date range filter works through provider chain', () {
        final container = createContainer();
        addTearDown(container.dispose);

        // Filter to Feb 20 only
        container.read(noteSearchProvider.notifier).setDateRange(
              DateTime(2026, 2, 20),
              DateTime(2026, 2, 20),
            );

        final results = container.read(filteredNotesProvider);

        expect(results, hasLength(2));
        expect(
          results.map((n) => n.title),
          containsAll(['Morning Standup', 'Lunch Break']),
        );
      });

      test('clearAll resets to showing all notes', () {
        final container = createContainer();
        addTearDown(container.dispose);

        // Apply filters
        final searchNotifier = container.read(noteSearchProvider.notifier);
        searchNotifier.setQuery('standup');
        searchNotifier.setCategoryFilter(workCategory);
        expect(container.read(filteredNotesProvider), hasLength(1));

        // Clear all
        searchNotifier.clearAll();
        expect(container.read(filteredNotesProvider), hasLength(4));
      });

      test('adding a note while filter is active updates filtered results',
          () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Set a filter
        container.read(noteSearchProvider.notifier).setQuery('meeting');
        expect(container.read(filteredNotesProvider), isEmpty);

        // Add a matching note
        await container.read(notesLocalDataProvider.notifier).addElement(
              makeTestNote(
                title: 'Team Meeting',
                description: 'Monthly review',
                from: DateTime(2026, 2, 22, 10, 0),
                category: workCategory,
              ),
            );

        // filteredNotesProvider should now include the new note
        final results = container.read(filteredNotesProvider);
        expect(results, hasLength(1));
        expect(results.first.title, 'Team Meeting');
      });

      test('deleting a note updates filtered results', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.read(noteSearchProvider.notifier).setQuery('standup');
        expect(container.read(filteredNotesProvider), hasLength(1));

        // Delete the matching note
        await container
            .read(notesLocalDataProvider.notifier)
            .deleteElement(testNotes[0]);

        expect(container.read(filteredNotesProvider), isEmpty);
      });
    });

    group('favorites filter through provider chain', () {
      test('toggling favorites filter shows only favorite notes', () {
        final favNotes = [
          makeTestNote(
            id: 'f1',
            title: 'Fav Note',
            description: 'Favorite',
            from: DateTime(2026, 2, 20, 9, 0),
            isFavorite: true,
          ),
          makeTestNote(
            id: 'f2',
            title: 'Regular Note',
            description: 'Not favorite',
            from: DateTime(2026, 2, 20, 10, 0),
            isFavorite: false,
          ),
        ];

        final container = createContainer(notes: favNotes);
        addTearDown(container.dispose);

        // All notes initially
        expect(container.read(filteredNotesProvider), hasLength(2));

        // Toggle favorites
        container.read(noteSearchProvider.notifier).toggleFavoritesOnly();
        final results = container.read(filteredNotesProvider);

        expect(results, hasLength(1));
        expect(results.first.title, 'Fav Note');
      });
    });
  });
}
