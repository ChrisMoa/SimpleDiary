import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';

class DiaryDayDetailPage extends ConsumerWidget {
  final DateTime selectedDate;

  const DiaryDayDetailPage({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryDayAsync = ref.watch(diaryDayForDateProvider(selectedDate));
    final notesAsync = ref.watch(notesForDayProvider(selectedDate));
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainer,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(l10n.dayDetail(_formatDate(selectedDate, locale))),
      ),
      body: diaryDayAsync.when(
        data: (diaryDay) {
          if (diaryDay == null) {
            return Center(
              child: Text(
                l10n.noDiaryEntryForDay,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return notesAsync.when(
            data: (notes) => _buildDiaryDayDetail(context, ref, diaryDay, notes),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(l10n.errorLoadingNotes(error.toString())),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.errorLoadingDiaryDay(error.toString())),
        ),
      ),
    );
  }

  Widget _buildDiaryDayDetail(
    BuildContext context,
    WidgetRef ref,
    DiaryDay diaryDay,
    List<Note> notes,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final overallScore = diaryDay.overallScore;

    return ListView(
      padding: AppSpacing.paddingAllMd,
      children: [
        // Day summary card
        AppCard.elevated(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: AppRadius.borderRadiusMd,
          padding: AppSpacing.paddingAllMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.daySummary,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalMd,
              _buildRatingsSummary(context, diaryDay),
              AppSpacing.verticalMd,
              _buildOverallMood(context, overallScore),
            ],
          ),
        ),

        AppSpacing.verticalXl,

        // Notes section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.notesAndActivities,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (notes.isNotEmpty)
              Text(
                l10n.nEntries(notes.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        AppSpacing.verticalXs,
        notes.isEmpty
            ? _buildEmptyNotesMessage(context)
            : _buildNotesList(context, ref, notes),
      ],
    );
  }

  Widget _buildRatingsSummary(BuildContext context, DiaryDay diaryDay) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: diaryDay.ratings.map<Widget>((rating) {
        final ratingLabel = _getLocalizedRatingLabel(l10n, rating.dayRating);
        return _buildRatingChip(context, l10n, ratingLabel, rating.score);
      }).toList(),
    );
  }

  Widget _buildRatingChip(BuildContext context, AppLocalizations l10n, String label, int rating) {
    final theme = Theme.of(context);
    final color = _getRatingColor(rating);

    return Chip(
      label: Text(
        '$label: ${_getLocalizedRatingText(l10n, rating)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(
          alpha: theme.colorScheme.brightness == Brightness.dark ? 0.15 : 0.1),
      side: BorderSide(color: color),
      avatar: Icon(
        _getRatingIcon(rating),
        color: color,
        size: 18,
      ),
    );
  }

  Widget _buildOverallMood(BuildContext context, int score) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const maxScore = 20;
    final percentage = score / maxScore;

    Color scoreColor = _getScoreColor(percentage);
    String moodText = _getLocalizedMoodText(l10n, percentage);

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: scoreColor.withValues(
              alpha: theme.colorScheme.brightness == Brightness.dark ? 0.3 : 0.2),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.overallMood(moodText),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalXxs,
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyNotesMessage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return AppCard.elevated(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: AppRadius.borderRadiusMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          AppSpacing.verticalMd,
          Text(
            l10n.noNotesForDay,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            l10n.addThoughtsActivitiesMemories,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, WidgetRef ref, List<Note> notes) {
    final sortedNotes = [...notes]..sort((a, b) => a.from.compareTo(b.from));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildNoteItem(context, ref, note);
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, WidgetRef ref, Note note) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return AppCard.flat(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: AppRadius.borderRadiusSm,
      onTap: () => _viewNote(context, ref, note),
      padding: AppSpacing.paddingAllSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: note.noteCategory.color,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editNote(context, ref, note),
                tooltip: l10n.editNote,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          if (note.description.isNotEmpty) ...[
            AppSpacing.verticalXs,
            Text(
              note.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppSpacing.verticalXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              AppSpacing.horizontalXxs,
              Text(
                note.isAllDay
                    ? l10n.allDay
                    : '${_formatTime(note.from)} - ${_formatTime(note.to)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Rating helpers ---

  IconData _getRatingIcon(int rating) {
    if (rating <= 1) return Icons.sentiment_very_dissatisfied;
    if (rating == 2) return Icons.sentiment_dissatisfied;
    if (rating == 3) return Icons.sentiment_neutral;
    if (rating == 4) return Icons.sentiment_satisfied;
    return Icons.sentiment_very_satisfied;
  }

  String _getLocalizedRatingText(AppLocalizations l10n, int rating) {
    if (rating <= 1) return l10n.ratingPoor;
    if (rating == 2) return l10n.ratingFair;
    if (rating == 3) return l10n.ratingGood;
    if (rating == 4) return l10n.ratingGreat;
    return l10n.ratingExcellent;
  }

  String _getLocalizedRatingLabel(AppLocalizations l10n, DayRatings dayRating) {
    switch (dayRating) {
      case DayRatings.social:
        return l10n.ratingSocial;
      case DayRatings.productivity:
        return l10n.ratingProductivity;
      case DayRatings.sport:
        return l10n.ratingSport;
      case DayRatings.food:
        return l10n.ratingFood;
    }
  }

  String _getLocalizedMoodText(AppLocalizations l10n, double percentage) {
    if (percentage < 0.3) return l10n.moodToughDay;
    if (percentage < 0.5) return l10n.moodCouldBeBetter;
    if (percentage < 0.7) return l10n.moodPrettyGood;
    if (percentage < 0.9) return l10n.moodGreatDay;
    return l10n.moodPerfectDay;
  }

  Color _getScoreColor(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    if (percentage < 0.7) return Colors.amber;
    if (percentage < 0.9) return Colors.lightGreen;
    return Colors.green;
  }

  Color _getRatingColor(int rating) {
    if (rating <= 1) return Colors.red;
    if (rating == 2) return Colors.orange;
    if (rating == 3) return Colors.amber;
    if (rating == 4) return Colors.lightGreen;
    return Colors.green;
  }

  // --- Formatting helpers ---

  String _formatDate(DateTime date, String locale) {
    return DateFormat('EEEE, MMM d, y', locale).format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // --- Navigation ---

  void _viewNote(BuildContext context, WidgetRef ref, Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteViewingPage(),
      ),
    );
  }

  void _editNote(BuildContext context, WidgetRef ref, Note note) {
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditingPage(
          editNote: true,
          navigateBack: true,
        ),
      ),
    );
  }
}

// Providers for loading diary day data on this page
final diaryDayForDateProvider = FutureProvider.family<DiaryDay?, DateTime>(
  (ref, date) async {
    final diaryDays = ref.watch(diaryDayFullDataProvider);

    final found = diaryDays
        .where((diaryDay) =>
            diaryDay.day.year == date.year &&
            diaryDay.day.month == date.month &&
            diaryDay.day.day == date.day)
        .toList();

    if (found.isEmpty) {
      return null;
    }
    return found.first;
  },
);

final notesForDayProvider = FutureProvider.family<List<Note>, DateTime>(
  (ref, date) async {
    final diaryDay = await ref.watch(diaryDayForDateProvider(date).future);

    if (diaryDay == null) {
      return [];
    }

    return diaryDay.notes;
  },
);
