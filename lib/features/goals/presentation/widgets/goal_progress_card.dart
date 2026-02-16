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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(progress.status, theme).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _buildCategoryIcon(context, goal.category),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 16),

              // Progress bar with endowed progress effect
              _buildProgressBar(context, progress),
              const SizedBox(height: 8),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    'Current',
                    progress.currentAverage.toStringAsFixed(1),
                    theme.colorScheme.primary,
                  ),
                  _buildStatItem(
                    context,
                    'Target',
                    goal.targetValue.toStringAsFixed(1),
                    _getStatusColor(progress.status, theme),
                  ),
                  _buildStatItem(
                    context,
                    'Days Left',
                    goal.daysRemaining.toString(),
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(progress.status),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
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
    final color = _getStatusColor(progress.status, theme);

    // Use absolute progress for display
    final percent = progress.absoluteProgressPercent.clamp(0.0, 1.0);
    final percentText = '${(percent * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              percentText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Background
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Progress fill
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
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

  String _getCategoryName(DayRatings category, AppLocalizations? l10n) {
    switch (category) {
      case DayRatings.social:
        return 'Social';
      case DayRatings.productivity:
        return 'Productivity';
      case DayRatings.sport:
        return 'Sport';
      case DayRatings.food:
        return 'Food';
    }
  }

  String _getTimeframeLabel(Goal goal, AppLocalizations? l10n) {
    final timeframe = goal.timeframe == GoalTimeframe.weekly
        ? 'Weekly'
        : 'Monthly';
    return '$timeframe • ${goal.daysRemaining} days left';
  }
}
