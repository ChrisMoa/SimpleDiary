import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:flutter/material.dart';

/// Card widget for displaying insights
class InsightCard extends StatelessWidget {
  final Insight insight;

  const InsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getInsightColor(insight.type, theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    insight.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getInsightColor(InsightType type, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    // Use theme primary and error colors only for accents
    switch (type) {
      case InsightType.achievement:
        return colorScheme.primary;
      case InsightType.improvement:
        return colorScheme.primary;
      case InsightType.warning:
        return colorScheme.error;
      case InsightType.suggestion:
        return colorScheme.primary;
      case InsightType.milestone:
        return colorScheme.primary;
    }
  }
}
