import 'package:day_tracker/features/dashboard/presentation/pages/favorites_overview_page.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/favorite_diary_days_provider.dart';
import 'package:day_tracker/core/navigation/drawer_index_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/favorite_notes_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FavoritesSectionWidget extends ConsumerWidget {
  const FavoritesSectionWidget({super.key});

  static const int _maxDisplayCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteDays = ref.watch(favoriteDiaryDaysProvider);
    final favoriteNotes = ref.watch(favoriteNotesProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Don't show section if no favorites
    if (favoriteDays.isEmpty && favoriteNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCount = favoriteDays.length + favoriteNotes.length;
    final hasMore = totalCount > _maxDisplayCount;

    // Build a limited list of items: take days first, then notes, up to max
    final limitedDays = favoriteDays.take(_maxDisplayCount).toList();
    final remainingSlots = _maxDisplayCount - limitedDays.length;
    final limitedNotes = favoriteNotes.take(remainingSlots).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              AppSpacing.horizontalXs,
              Text(
                l10n.favorites,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.horizontalXs,
              Text(
                '($totalCount)',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (hasMore)
                TextButton(
                  onPressed: () => _navigateToFavoritesOverview(context),
                  child: Text(l10n.viewAll),
                ),
            ],
          ),
        ),

        // Horizontal scroll with limited favorites
        SizedBox(
          height: 115,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              ...limitedDays.asMap().entries.map(
                (entry) => AnimatedListItem(
                  index: entry.key,
                  child: _buildFavoriteDayCard(context, ref, entry.value),
                ),
              ),
              ...limitedNotes.asMap().entries.map(
                (entry) => AnimatedListItem(
                  index: limitedDays.length + entry.key,
                  child: _buildFavoriteNoteCard(context, ref, entry.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteDayCard(
      BuildContext context, WidgetRef ref, DiaryDay day) {
    final theme = Theme.of(context);
    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: AppRadius.borderRadiusMd,
      onTap: () => _navigateToDayDetail(context, ref, day),
      child: Container(
        width: 120,
        padding: AppSpacing.paddingAllSm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM d').format(day.day),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalXxs,
            Text(
              DateFormat('EEEE').format(day.day),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.verticalXs,
            _buildScoreIndicator(context, day.overallScore),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteNoteCard(
      BuildContext context, WidgetRef ref, Note note) {
    final theme = Theme.of(context);
    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: AppRadius.borderRadiusMd,
      onTap: () => _navigateToNoteDetail(context, ref, note),
      child: Container(
        width: 160,
        padding: AppSpacing.paddingAllSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: note.noteCategory.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
              AppSpacing.verticalXxs,
              Text(
                DateFormat('MMM d, yyyy').format(note.from),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (note.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  note.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
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
        borderRadius: AppRadius.borderRadiusMd,
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

  void _navigateToFavoritesOverview(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute(
        builder: (context) => const FavoritesOverviewPage(),
      ),
    );
  }

  void _navigateToDayDetail(
      BuildContext context, WidgetRef ref, DiaryDay day) {
    ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(day.day);
    ref.read(selectedDrawerIndexProvider.notifier).state = 3;
  }

  void _navigateToNoteDetail(
      BuildContext context, WidgetRef ref, Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(note.from);
    Navigator.push(
      context,
      AppPageRoute(
        builder: (context) => const NoteEditingPage(editNote: true),
      ),
    );
  }
}
