import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/models/goal_progress.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final goal = progress.goal;

    return AppCard.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: _getStatusColor(progress.status, theme).withValues(alpha: 0.3),
      onTap: onTap,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
                children: [
                  _buildCategoryIcon(context, goal.category),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryName(goal.category, l10n),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _getTimeframeLabel(goal, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, progress),
                ],
              ),
              AppSpacing.verticalMd,

              // Progress bar with endowed progress effect
              _buildProgressBar(context, progress),
              AppSpacing.verticalXs,

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    l10n.goalCurrentAverage,
                    progress.currentAverage.toStringAsFixed(1),
                    theme.colorScheme.primary,
                  ),
                  _buildStatItem(
                    context,
                    l10n.goalTarget,
                    goal.targetValue.toStringAsFixed(1),
                    _getStatusColor(progress.status, theme),
                  ),
                  _buildStatItem(
                    context,
                    l10n.goalDaysRemaining,
                    goal.daysRemaining.toString(),
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, DayRatings category) {
    IconData icon;
    Color color;
    switch (category) {
      case DayRatings.social:
        icon = Icons.people;
        color = Colors.blue;
        break;
      case DayRatings.productivity:
        icon = Icons.work;
        color = Colors.orange;
        break;
      case DayRatings.sport:
        icon = Icons.fitness_center;
        color = Colors.green;
        break;
      case DayRatings.food:
        icon = Icons.restaurant;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GoalProgress progress) {
    final theme = Theme.of(context);
    final color = _getStatusColor(progress.status, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(progress.status),
            size: 14,
            color: color,
          ),
          AppSpacing.horizontalXxs,
          Text(
            progress.statusMessage,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, GoalProgress progress) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = _getStatusColor(progress.status, theme);

    // Use absolute progress for display
    final percent = progress.absoluteProgressPercent.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.goalProgress,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AnimatedCounter(
              value: percent * 100,
              suffix: '%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedProgressBar(
          value: percent,
          color: color,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ProgressStatus status, ThemeData theme) {
    switch (status) {
      case ProgressStatus.completed:
      case ProgressStatus.ahead:
        return Colors.green;
      case ProgressStatus.onTrack:
        return Colors.blue;
      case ProgressStatus.behind:
        return Colors.orange;
      case ProgressStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.completed:
        return Icons.check_circle;
      case ProgressStatus.ahead:
        return Icons.trending_up;
      case ProgressStatus.onTrack:
        return Icons.check;
      case ProgressStatus.behind:
        return Icons.warning;
      case ProgressStatus.failed:
        return Icons.close;
    }
  }

  String _getCategoryName(DayRatings category, AppLocalizations l10n) {
    switch (category) {
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

  String _getTimeframeLabel(Goal goal, AppLocalizations l10n) {
    final timeframe = goal.timeframe == GoalTimeframe.weekly
        ? l10n.goalWeekly
        : l10n.goalMonthly;
    return '$timeframe • ${goal.daysRemaining} ${l10n.goalDaysLeft}';
  }
}
