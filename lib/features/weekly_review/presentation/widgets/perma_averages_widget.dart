import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

/// Horizontal bar chart showing PERMA+ dimension averages for the week.
class PermaAveragesWidget extends StatelessWidget {
  final WeeklyReviewData review;

  const PermaAveragesWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final averages = review.permaAverages;

    if (averages.isEmpty) return const SizedBox.shrink();

    final dimensions = [
      ('mood', 'P - Positive Emotion', Icons.sentiment_satisfied_alt),
      ('energy', 'V - Vitality', Icons.bolt),
      ('connection', 'R - Relationships', Icons.people),
      ('purpose', 'M - Meaning', Icons.flag),
      ('achievement', 'A - Accomplishment', Icons.emoji_events),
      ('engagement', 'E - Engagement', Icons.psychology),
    ];

    return AppCard.elevated(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.permaAverages,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,
          ...dimensions.map((dim) {
            final value = averages[dim.$1] ?? 0.0;
            return _buildDimensionBar(
              context,
              label: dim.$2,
              icon: dim.$3,
              value: value,
              maxValue: 5.0,
              theme: theme,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDimensionBar(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double value,
    required double maxValue,
    required ThemeData theme,
  }) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: AppSpacing.paddingVerticalXs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          AnimatedProgressBar(
            value: progress,
            height: 8,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
