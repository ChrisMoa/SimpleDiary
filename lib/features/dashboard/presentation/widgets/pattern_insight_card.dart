import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';

/// Card widget for displaying pattern-based insights with visualization
class PatternInsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onTap;

  const PatternInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = insight.patternData;

    return AppCard.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: _getTypeColor(insight.type, theme).withValues(alpha: 0.3),
      onTap: onTap,
      padding: AppSpacing.paddingAllMd,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type badge
              Row(
                children: [
                  _buildTypeIcon(context),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _buildTypeBadge(context),
                      ],
                    ),
                  ),
                  if (pattern != null && pattern.isStrong)
                    _buildStrengthIndicator(context, pattern.strengthPercent),
                ],
              ),
              AppSpacing.verticalSm,

              // Description
              Text(
                insight.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Pattern visualization (if applicable)
              if (pattern != null && insight.type == InsightType.correlation)
                _buildCorrelationVisualization(context, pattern),
            ],
          ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTypeColor(insight.type, theme);

    IconData icon;
    switch (insight.icon) {
      case 'trending_up':
        icon = Icons.trending_up;
        break;
      case 'trending_down':
        icon = Icons.trending_down;
        break;
      case 'calendar_today':
        icon = Icons.calendar_today;
        break;
      case 'lightbulb':
        icon = Icons.lightbulb_outline;
        break;
      case 'info':
        icon = Icons.info_outline;
        break;
      default:
        icon = Icons.insights;
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

  Widget _buildTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTypeColor(insight.type, theme);

    String label;
    switch (insight.type) {
      case InsightType.correlation:
        label = 'Pattern';
        break;
      case InsightType.trend:
        label = 'Trend';
        break;
      case InsightType.dayPattern:
        label = 'Weekly';
        break;
      case InsightType.recommendation:
        label = 'Tip';
        break;
      default:
        label = 'Insight';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator(BuildContext context, int strengthPercent) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_graph,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          AppSpacing.horizontalXxs,
          Text(
            '$strengthPercent%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationVisualization(
      BuildContext context, PatternData pattern) {
    final theme = Theme.of(context);
    final stats = pattern.statistics;

    if (stats == null) return const SizedBox.shrink();

    final withActivity = (stats['withActivity'] as num?)?.toDouble() ?? 0;
    final withoutActivity = (stats['withoutActivity'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildComparisonBar(
              context,
              'With ${pattern.activityCategory}',
              withActivity,
              theme.colorScheme.primary,
            ),
          ),
          AppSpacing.horizontalSm,
          Expanded(
            child: _buildComparisonBar(
              context,
              'Without',
              withoutActivity,
              theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage = (value / 5.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.verticalXxs,
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(1),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(InsightType type, ThemeData theme) {
    switch (type) {
      case InsightType.correlation:
        return Colors.blue;
      case InsightType.trend:
        return Colors.green;
      case InsightType.dayPattern:
        return Colors.orange;
      case InsightType.recommendation:
        return Colors.purple;
      case InsightType.achievement:
        return Colors.amber;
      case InsightType.milestone:
        return Colors.teal;
      case InsightType.warning:
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
}
