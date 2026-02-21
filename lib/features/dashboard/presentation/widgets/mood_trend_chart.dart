import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mood trend chart showing score trends over time
class MoodTrendChart extends ConsumerWidget {
  const MoodTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    // Get theme for reactive updates
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final l10n = AppLocalizations.of(context)!;

    return statsAsync.when(
      loading: () => AppCard.elevated(
        margin: AppSpacing.paddingAllMd,
        padding: AppSpacing.paddingAllXl,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AppCard.elevated(
        margin: AppSpacing.paddingAllMd,
        padding: AppSpacing.paddingAllXl,
        child: Text(l10n.errorWithMessage(error.toString())),
      ),
      data: (stats) {
        final dailyScores = stats.weekStats.dailyScores;

        if (dailyScores.isEmpty) {
          return AppCard.elevated(
            margin: AppSpacing.paddingAllMd,
            padding: AppSpacing.paddingAllXl,
            child: Center(
              child: Text(
                l10n.noDataAvailable,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }

        return AppCard.elevated(
          margin: AppSpacing.paddingAllMd,
          padding: AppSpacing.paddingAllMd,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ratingTrend,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalXl,
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colorScheme.outline.withValues(alpha:0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: theme.textTheme.labelSmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < dailyScores.length) {
                                final date = dailyScores[value.toInt()].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${date.day}.${date.month}',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (dailyScores.length - 1).toDouble(),
                      minY: 0,
                      maxY: 20,
                      lineBarsData: [
                        LineChartBarData(
                          spots: dailyScores.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.totalScore.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withValues(alpha:0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final date = dailyScores[spot.x.toInt()].date;
                              return LineTooltipItem(
                                '${date.day}.${date.month}\n${l10n.score(spot.y.toInt())}',
                                TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        );
      },
    );
  }
}
