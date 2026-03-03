import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

/// Shows notable entries (favorites), streak info, and score summary.
class ReviewHighlightsWidget extends StatelessWidget {
  final WeeklyReviewData review;
  final WeeklyReviewData? previousReview;

  const ReviewHighlightsWidget({
    super.key,
    required this.review,
    this.previousReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final highlights = review.highlights;
    final colorScheme = theme.colorScheme;

    final favoriteDays = List<String>.from(highlights['favoriteDays'] as List? ?? []);
    final favoriteNotes = List<Map<String, dynamic>>.from(
      (highlights['favoriteNotes'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    return AppCard.elevated(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.streakAndProgress,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,

          // Streak & score row
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  theme: theme,
                  icon: '🔥',
                  value: '${review.currentStreak}',
                  label: l10n.dayStreak,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _buildStatBox(
                  theme: theme,
                  icon: '⭐',
                  value: review.averageScore.toStringAsFixed(1),
                  label: _scoreComparisonLabel(l10n),
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _buildStatBox(
                  theme: theme,
                  icon: '📅',
                  value: '${review.completedDays}/7',
                  label: l10n.completedDaysCount(review.completedDays).split('/').first.trim(),
                ),
              ),
            ],
          ),

          // Favorite days
          if (favoriteDays.isNotEmpty) ...[
            AppSpacing.verticalMd,
            Row(
              children: [
                Icon(Icons.favorite, size: 18, color: colorScheme.error),
                AppSpacing.horizontalXs,
                Flexible(
                  child: Text(
                    l10n.favoriteDays,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalXs,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: favoriteDays.map((date) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Favorite notes
          if (favoriteNotes.isNotEmpty) ...[
            AppSpacing.verticalMd,
            Row(
              children: [
                Icon(Icons.bookmark, size: 18, color: colorScheme.primary),
                AppSpacing.horizontalXs,
                Flexible(
                  child: Text(
                    l10n.favoriteNotes,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalXs,
            ...favoriteNotes.map((note) {
              final title = note['title'] as String? ?? '';
              final category = note['category'] as String? ?? '';
              return Padding(
                padding: AppSpacing.paddingVerticalXs,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: colorScheme.primary),
                    AppSpacing.horizontalXs,
                    Expanded(
                      child: Text(
                        title.isNotEmpty ? title : category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (category.isNotEmpty && title.isNotEmpty)
                      Text(
                        category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required ThemeData theme,
    required String icon,
    required String value,
    required String label,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingAllSm,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          AppSpacing.verticalXxs,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalXxs,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _scoreComparisonLabel(AppLocalizations l10n) {
    if (previousReview == null) return l10n.weeklyAverage;
    final diff = review.averageScore - previousReview!.averageScore;
    final sign = diff >= 0 ? '+' : '';
    return '${l10n.vsLastWeek} ($sign${diff.toStringAsFixed(1)})';
  }
}
