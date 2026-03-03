import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Mon–Sun day cards showing daily scores with color coding.
class WeekScoreOverview extends StatelessWidget {
  final WeeklyReviewData review;

  const WeekScoreOverview({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scores = review.dailyScores;

    return AppCard.elevated(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyScoreOverview,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final day = scores[index];
                return AnimatedListItem(
                  index: index,
                  child: _buildDayCard(context, day, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    Map<String, dynamic> day,
    ThemeData theme,
  ) {
    final date = DateFormat('dd.MM.yyyy').parse(day['date'] as String);
    final score = day['score'] as int? ?? 0;
    final isComplete = day['isComplete'] as bool? ?? false;
    final noteCount = day['noteCount'] as int? ?? 0;

    final dayName = DateFormat('E').format(date);
    final dayNumber = DateFormat('d').format(date);
    final colorScheme = theme.colorScheme;

    final cardColor = isComplete
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Padding(
        padding: AppSpacing.paddingAllSm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  dayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  dayNumber,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (isComplete)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getScoreColor(score).withValues(alpha: 0.3),
                  border: Border.all(
                    color: _getScoreColor(score),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  Icons.remove,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            if (noteCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note, size: 12, color: colorScheme.primary),
                  AppSpacing.horizontalXxs,
                  Text(
                    '$noteCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 16) return Colors.green.shade600;
    if (score >= 12) return Colors.lightGreen.shade600;
    if (score >= 8) return Colors.amber.shade700;
    if (score >= 4) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
