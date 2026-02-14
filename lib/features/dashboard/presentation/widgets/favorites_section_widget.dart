import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/favorite_diary_days_provider.dart';
import 'package:day_tracker/features/day_rating/presentation/pages/diary_day_wizard_page.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/favorite_notes_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FavoritesSectionWidget extends ConsumerWidget {
  const FavoritesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteDays = ref.watch(favoriteDiaryDaysProvider);
    final favoriteNotes = ref.watch(favoriteNotesProvider);
    final theme = Theme.of(context);

    // Don't show section if no favorites
    if (favoriteDays.isEmpty && favoriteNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Favorites', // TODO: localize
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Favorite days (show up to 5 in horizontal scroll)
        if (favoriteDays.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Favorite Days', // TODO: localize
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: favoriteDays.take(5).length,
              itemBuilder: (context, index) {
                final day = favoriteDays[index];
                return _buildFavoriteDayCard(context, ref, day);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Favorite notes (show up to 5)
        if (favoriteNotes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Favorite Notes', // TODO: localize
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...favoriteNotes
              .take(5)
              .map((note) => _buildFavoriteNoteCard(context, ref, note)),
        ],
      ],
    );
  }

  Widget _buildFavoriteDayCard(BuildContext context, WidgetRef ref, DiaryDay day) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToDayDetail(context, ref, day),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM d').format(day.day),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE').format(day.day),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildScoreIndicator(context, day.overallScore),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteNoteCard(
      BuildContext context, WidgetRef ref, Note note) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: note.noteCategory.color.withValues(alpha: 0.2),
          child: Icon(
            Icons.note,
            color: note.noteCategory.color,
            size: 20,
          ),
        ),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(note.from),
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.star, color: Colors.amber, size: 20),
        onTap: () => _navigateToNoteDetail(context, ref, note),
      ),
    );
  }

  Widget _buildScoreIndicator(BuildContext context, int score) {
    final theme = Theme.of(context);
    final maxScore = 20; // Assuming 4 categories * 5 max score
    final percentage = score / maxScore;

    Color scoreColor;
    if (percentage < 0.3) {
      scoreColor = Colors.red;
    } else if (percentage < 0.5) {
      scoreColor = Colors.orange;
    } else if (percentage < 0.7) {
      scoreColor = Colors.amber;
    } else if (percentage < 0.9) {
      scoreColor = Colors.lightGreen;
    } else {
      scoreColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.7 : 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$score',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToDayDetail(BuildContext context, WidgetRef ref, DiaryDay day) {
    ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(day.day);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiaryDayWizardPage(),
      ),
    );
  }

  void _navigateToNoteDetail(BuildContext context, WidgetRef ref, Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(note.from);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditingPage(editNote: true),
      ),
    );
  }
}
