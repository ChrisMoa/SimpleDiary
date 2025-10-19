import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Activity heatmap showing daily entries over the year
class ActivityHeatmap extends ConsumerWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryDays = ref.watch(diaryDayLocalDbDataProvider);
    // Get theme for reactive updates
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate last 12 weeks
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 84)); // 12 weeks

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitäts-Heatmap',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 84,
                itemBuilder: (context, index) {
                  final date = startDate.add(Duration(days: index));
                  final dayData = diaryDays.where((d) => Utils.isSameDay(d.day, date)).firstOrNull;
                  
                  Color cellColor;
                  if (dayData == null) {
                    cellColor = colorScheme.surfaceContainerHighest;
                  } else {
                    final score = dayData.overallScore;
                    // Use subtle theme primary color with low opacity
                    if (score >= 16) {
                      cellColor = colorScheme.primary.withOpacity(0.6);
                    } else if (score >= 12) {
                      cellColor = colorScheme.primary.withOpacity(0.4);
                    } else if (score >= 8) {
                      cellColor = colorScheme.primary.withOpacity(0.25);
                    } else {
                      cellColor = colorScheme.primary.withOpacity(0.15);
                    }
                  }

                  return Tooltip(
                    message: '${date.day}.${date.month}.${date.year}\n${dayData?.overallScore ?? 0} Punkte',
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Weniger', style: theme.textTheme.labelSmall),
                const SizedBox(width: 8),
                _buildLegendBox(colorScheme.surfaceContainerHighest),
                _buildLegendBox(colorScheme.primary.withOpacity(0.15)),
                _buildLegendBox(colorScheme.primary.withOpacity(0.25)),
                _buildLegendBox(colorScheme.primary.withOpacity(0.4)),
                _buildLegendBox(colorScheme.primary.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text('Mehr', style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
