import 'package:day_tracker/core/utils/responsive_breakpoints.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/activity_heatmap.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/mood_trend_chart.dart';
import 'package:flutter/material.dart';

/// Section displaying statistics and charts
class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Statistiken',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (isDesktop)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: MoodTrendChart()),
              Expanded(child: ActivityHeatmap()),
            ],
          )
        else ...[
          const MoodTrendChart(),
          const ActivityHeatmap(),
        ],
      ],
    );
  }
}
