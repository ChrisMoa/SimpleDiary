import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/dashboard/data/repositories/activity_detail_repository.dart';
import 'package:day_tracker/features/dashboard/domain/providers/activity_detail_provider.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/diary_day_detail_page.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_viewing_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Page showing detailed statistics and entries for a specific activity category
class ActivityDetailPage extends ConsumerWidget {
  final String activityName;

  const ActivityDetailPage({super.key, required this.activityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(activityStatsProvider(activityName));
    final activityNotes = ref.watch(notesByActivityProvider(activityName));
    final activityDays = ref.watch(daysByActivityProvider(activityName));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainer,
        foregroundColor: theme.colorScheme.onSurface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: stats.category.color,
              radius: 8,
            ),
            AppSpacing.horizontalXs,
            Flexible(
              child: Text(
                l10n.activityDetails,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: PageGradientBackground(
        child: ListView(
          padding: AppSpacing.paddingAllMd,
          children: [
            // Activity name header
            _buildHeader(context, stats),
            AppSpacing.verticalMd,

            // Summary stats card
            _buildSummaryCard(context, stats, locale),
            AppSpacing.verticalXl,

            // Associated days section
            if (activityDays.isNotEmpty) ...[
              _buildSectionTitle(context, l10n.associatedDays, activityDays.length),
              AppSpacing.verticalXs,
              ...activityDays.take(10).map((day) =>
                  _buildDayItem(context, day, locale)),
              if (activityDays.length > 10)
                Padding(
                  padding: AppSpacing.paddingVerticalXs,
                  child: Text(
                    l10n.andMoreEntries(activityDays.length - 10),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              AppSpacing.verticalXl,
            ],

            // Notes section
            if (activityNotes.isNotEmpty) ...[
              _buildSectionTitle(context, l10n.notesInCategory, activityNotes.length),
              AppSpacing.verticalXs,
              ...activityNotes.take(20).map((note) =>
                  _buildNoteItem(context, ref, note)),
              if (activityNotes.length > 20)
                Padding(
                  padding: AppSpacing.paddingVerticalXs,
                  child: Text(
                    l10n.andMoreEntries(activityNotes.length - 20),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],

            // Bottom spacing
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ActivityStats stats) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: stats.category.color.withValues(alpha: 0.2),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Icon(
            Icons.category_rounded,
            color: stats.category.color,
            size: 28,
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Text(
            stats.activityName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, ActivityStats stats, String locale) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard.elevated(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: AppRadius.borderRadiusMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.note_outlined,
                  label: l10n.totalNotes,
                  value: stats.totalNotes.toString(),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: l10n.associatedDays,
                  value: stats.associatedDays.toString(),
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.star_outline_rounded,
                  label: l10n.averageRating,
                  value: stats.averageDayRating > 0
                      ? stats.averageDayRating.toStringAsFixed(1)
                      : '-',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.date_range_outlined,
                  label: l10n.dateRange,
                  value: _formatDateRange(stats, locale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        AppSpacing.verticalXs,
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          l10n.nEntries(count),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(BuildContext context, DiaryDay day, String locale) {
    final theme = Theme.of(context);
    final score = day.overallScore;
    final scoreColor = _getScoreColor(score / 20.0);

    return AppCard.flat(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 3),
      borderRadius: AppRadius.borderRadiusSm,
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => DiaryDayDetailPage(selectedDate: day.day),
          ),
        );
      },
      padding: AppSpacing.paddingAllSm,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scoreColor.withValues(
              alpha: theme.colorScheme.brightness == Brightness.dark ? 0.3 : 0.2,
            ),
            child: Text(
              '$score',
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, y', locale).format(day.day),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (day.notes.isNotEmpty)
                  Text(
                    '${day.notes.length} ${day.notes.length == 1 ? 'note' : 'notes'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, WidgetRef ref, Note note) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard.flat(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 3),
      borderRadius: AppRadius.borderRadiusSm,
      onTap: () {
        ref.read(noteEditingPageProvider.notifier).updateNote(note);
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => const NoteViewingPage(),
          ),
        );
      },
      padding: AppSpacing.paddingAllSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title.isNotEmpty ? note.title : activityName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (note.isFavorite)
                const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
          if (note.description.isNotEmpty) ...[
            AppSpacing.verticalXxs,
            Text(
              note.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppSpacing.verticalXxs,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              AppSpacing.horizontalXxs,
              Text(
                note.isAllDay
                    ? l10n.allDay
                    : '${DateFormat('MMM d', Localizations.localeOf(context).languageCode).format(note.from)}  ${DateFormat('HH:mm').format(note.from)} - ${DateFormat('HH:mm').format(note.to)}',
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

  String _formatDateRange(ActivityStats stats, String locale) {
    if (stats.firstOccurrence == null || stats.lastOccurrence == null) {
      return '-';
    }
    final fmt = DateFormat('MMM d', locale);
    return '${fmt.format(stats.firstOccurrence!)} - ${fmt.format(stats.lastOccurrence!)}';
  }

  Color _getScoreColor(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    if (percentage < 0.7) return Colors.amber;
    if (percentage < 0.9) return Colors.lightGreen;
    return Colors.green;
  }
}
