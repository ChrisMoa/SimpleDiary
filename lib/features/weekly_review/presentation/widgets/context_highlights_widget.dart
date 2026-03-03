import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

/// Shows contextual highlights: average sleep, exercise days, stress trend.
class ContextHighlightsWidget extends StatelessWidget {
  final WeeklyReviewData review;

  const ContextHighlightsWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final summary = review.contextSummary;

    final avgSleep = summary['avgSleep'] as num?;
    final avgSleepQuality = summary['avgSleepQuality'] as num?;
    final exerciseDays = summary['exerciseDays'] as int? ?? 0;
    final avgStress = summary['avgStress'] as num?;

    // Don't show if no context data at all
    if (avgSleep == null && avgSleepQuality == null && exerciseDays == 0 && avgStress == null) {
      return const SizedBox.shrink();
    }

    return AppCard.elevated(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contextHighlights,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (avgSleep != null)
                _buildStatTile(
                  theme: theme,
                  icon: Icons.bedtime,
                  label: l10n.averageSleep,
                  value: '${avgSleep.toStringAsFixed(1)}h',
                ),
              if (avgSleepQuality != null)
                _buildStatTile(
                  theme: theme,
                  icon: Icons.star,
                  label: l10n.averageSleepQuality,
                  value: '${avgSleepQuality.toStringAsFixed(1)}/5',
                ),
              _buildStatTile(
                theme: theme,
                icon: Icons.fitness_center,
                label: l10n.exerciseDays,
                value: '$exerciseDays/7',
              ),
              if (avgStress != null)
                _buildStatTile(
                  theme: theme,
                  icon: Icons.speed,
                  label: l10n.averageStress,
                  value: '${avgStress.toStringAsFixed(1)}/5',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: 140,
      padding: AppSpacing.paddingAllSm,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          AppSpacing.verticalXs,
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
          ),
        ],
      ),
    );
  }
}
