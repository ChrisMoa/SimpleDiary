import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestSettingsContainer();
  });

  group('NoteEditingPage', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // Title and description text fields
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      // Category dropdown
      expect(find.byType(DropdownButtonFormField<NoteCategory>),
          findsOneWidget);
      // All-day checkbox
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders title hint and description header', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // l10n English: "Add Title", "Description"
      expect(find.text('Add Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('renders from/to date-time pickers', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // l10n English: "FROM", "To"
      expect(find.text('FROM'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      // Drop-down arrow icons for date/time pickers (2 for From, 2 for To)
      expect(find.byIcon(Icons.arrow_drop_down), findsAtLeastNWidgets(4));
    });

    testWidgets('category dropdown shows all categories', (tester) async {
      final categories = [
        NoteCategory(title: 'Work', color: Colors.purple),
        NoteCategory(title: 'Leisure', color: Colors.lightBlue),
        NoteCategory(title: 'Food', color: Colors.amber),
      ];

      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(categories: categories),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll the dropdown into view, then tap it
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<NoteCategory>));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<NoteCategory>));
      await tester.pumpAndSettle();

      // All categories should be visible in the dropdown popup
      expect(find.text('Work'), findsAtLeastNWidgets(1));
      expect(find.text('Leisure'), findsAtLeastNWidgets(1));
      expect(find.text('Food'), findsAtLeastNWidgets(1));
    });

    testWidgets('all-day checkbox toggles correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isFalse);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets(
        'shows save and reload buttons when addAdditionalSaveButton is true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(
            body: NoteEditingPage(
              navigateBack: false,
              addAdditionalSaveButton: true,
            ),
          ),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // l10n English: "save", "reload" (lowercase)
      expect(find.text('save'), findsOneWidget);
      expect(find.text('reload'), findsOneWidget);
    });

    testWidgets('renders AppBar with save action when navigateBack is true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const NoteEditingPage(navigateBack: true),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // AppBar save button with done icon and "SAVE" text
      expect(find.byIcon(Icons.done), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      // Close button
      expect(find.byType(CloseButton), findsOneWidget);
    });

    testWidgets('pre-fills form when editing an existing note',
        (tester) async {
      final existingNote = Note(
        title: 'Test Note',
        description: 'Test Description',
        from: DateTime(2026, 2, 24, 10, 0),
        to: DateTime(2026, 2, 24, 11, 0),
        noteCategory: NoteCategory(title: 'Work', color: Colors.purple),
      );

      await tester.pumpWidget(
        createTestApp(
          const Scaffold(
            body: NoteEditingPage(navigateBack: false, editNote: true),
          ),
          overrides: createTestOverrides(
            additionalOverrides: [
              noteEditingPageProvider.overrideWith((_) {
                final notifier = NoteEditingPageProvider();
                notifier.updateNote(existingNote);
                return notifier;
              }),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title and description should be pre-filled
      expect(find.text('Test Note'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('allDay checkbox label is displayed', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Scaffold(body: NoteEditingPage(navigateBack: false)),
          overrides: createTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // l10n English: "AllDay?"
      expect(find.text('AllDay?'), findsOneWidget);
    });
  });
}
