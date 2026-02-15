import 'package:day_tracker/features/dashboard/presentation/pages/diary_day_detail_page.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_overview_list_item.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/favorite_diary_days_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/favorite_notes_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:day_tracker/features/notes/presentation/widgets/note_search_result_item.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesOverviewPage extends ConsumerWidget {
  const FavoritesOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteDays = ref.watch(favoriteDiaryDaysProvider);
    final favoriteNotes = ref.watch(favoriteNotesProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Build a mixed list sorted by date descending
    final items = <_FavoriteItem>[
      ...favoriteDays.map((day) => _FavoriteItem.day(day)),
      ...favoriteNotes.map((note) => _FavoriteItem.note(note)),
    ];
    items.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavorites,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.diaryDay != null) {
                  return DiaryDayOverviewListItem(
                    diaryDay: item.diaryDay!,
                    onSelectDiaryDay: (day) =>
                        _navigateToDayDetail(context, day),
                  );
                } else {
                  return NoteSearchResultItem(
                    note: item.noteItem!,
                    onSelectNote: (note) =>
                        _navigateToNoteDetail(context, ref, note),
                  );
                }
              },
            ),
    );
  }

  void _navigateToDayDetail(BuildContext context, DiaryDay day) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDayDetailPage(selectedDate: day.day),
      ),
    );
  }

  void _navigateToNoteDetail(
      BuildContext context, WidgetRef ref, Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteViewingPage(),
      ),
    );
  }
}

class _FavoriteItem {
  final DiaryDay? diaryDay;
  final Note? noteItem;
  final DateTime date;

  _FavoriteItem.day(DiaryDay day)
      : diaryDay = day,
        noteItem = null,
        date = day.day;

  _FavoriteItem.note(Note note)
      : diaryDay = null,
        noteItem = note,
        date = note.from;
}
