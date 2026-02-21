import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:day_tracker/features/notes/presentation/widgets/note_search_result_item.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesOverviewList extends ConsumerStatefulWidget {
  const NotesOverviewList({super.key});

  @override
  ConsumerState<NotesOverviewList> createState() => _NotesOverviewListState();
}

class _NotesOverviewListState extends ConsumerState<NotesOverviewList> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(filteredNotesProvider);
    final searchState = ref.watch(noteSearchProvider);

    return notes.isEmpty
        ? _buildEmptyList(searchState.isActive)
        : _buildFilledList(notes, searchState.query);
  }

  Widget _buildEmptyList(bool isSearchActive) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchActive ? Icons.search_off : Icons.note_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          AppSpacing.verticalMd,
          Text(
            isSearchActive ? l10n.noNotesMatchSearch : l10n.noDiaryEntriesYet,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (isSearchActive) ...[
            AppSpacing.verticalXs,
            Text(
              l10n.tryDifferentSearch,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilledList(List<Note> notes, String searchQuery) {
    return Column(
      children: [
        // Result count indicator
        if (searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '${notes.length} ${notes.length == 1 ? 'result' : 'results'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),

        // Notes list
        Expanded(
          child: ListView.builder(
            itemBuilder: (ctx, index) => NoteSearchResultItem(
              note: notes[index],
              onSelectNote: onSelectNote,
              searchQuery: searchQuery,
            ),
            itemCount: notes.length,
          ),
        ),
      ],
    );
  }

  void onSelectNote(Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    Navigator.of(context).push(AppPageRoute(
      builder: (context) => const NoteViewingPage(),
    ));
  }
}
