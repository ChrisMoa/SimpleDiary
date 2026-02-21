import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/dashboard/domain/providers/week_overview_provider.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/diary_day_detail_page.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Week overview widget showing the last 7 days
class WeekOverviewWidget extends ConsumerWidget {
  const WeekOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStatsAsync = ref.watch(weekOverviewProvider);
    final theme = Theme.of(context);

    return weekStatsAsync.when(
      loading: () => AppCard.elevated(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: AppSpacing.paddingAllXl,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AppCard.elevated(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: AppSpacing.paddingAllXl,
        child: Text(AppLocalizations.of(context)!.errorWithMessage(error.toString())),
      ),
      data: (weekStats) {
        return AppCard.elevated(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: AppSpacing.paddingAllMd,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.sevenDayOverview,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekStats.dailyScores.length,
                    itemBuilder: (context, index) {
                      final dayScore = weekStats.dailyScores[index];
                      return _buildDayCard(context, dayScore, theme);
                    },
                  ),
                ),
              ],
            ),
        );
      },
    );
  }

  Widget _buildDayCard(BuildContext context, dynamic dayScore, ThemeData theme) {
    final date = dayScore.date as DateTime;
    final isToday = Utils.isSameDay(date, DateTime.now());
    final isComplete = dayScore.isComplete as bool;
    final totalScore = dayScore.totalScore as int;
    final noteCount = dayScore.noteCount as int;

    final dayName = DateFormat('EEE', 'de').format(date);
    final dayNumber = DateFormat('d', 'de').format(date);

    final colorScheme = theme.colorScheme;
    
    // Use neutral colors for all cards
    Color cardColor;
    if (!isComplete) {
      cardColor = colorScheme.surfaceContainerHighest;
    } else {
      // All completed days get same neutral surface
      cardColor = colorScheme.surfaceContainerHigh;
    }

    return GestureDetector(
      onTap: () {
        if (isComplete) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiaryDayDetailPage(selectedDate: date),
            ),
          );
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.borderRadiusMd,
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Padding(
          padding: AppSpacing.paddingAllSm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day name and number
              Column(
                children: [
                  Text(
                    dayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    dayNumber,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              // Score circle
              if (isComplete)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getScoreColor(totalScore, colorScheme).withValues(alpha:0.3),
                    border: Border.all(
                      color: _getScoreColor(totalScore, colorScheme),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$totalScore',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(totalScore, colorScheme),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: colorScheme.onSurface.withValues(alpha:0.3),
                  ),
                ),

              // Note count badge
              if (noteCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha:0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      AppSpacing.horizontalXxs,
                      Text(
                        '$noteCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score, ColorScheme colorScheme) {
    // Use semantic colors independent of theme for better readability
    if (score >= 16) return Colors.green.shade600;      // Excellent
    if (score >= 12) return Colors.lightGreen.shade600; // Good
    if (score >= 8) return Colors.amber.shade700;       // OK
    if (score >= 4) return Colors.orange.shade700;      // Below average
    return Colors.red.shade700;                          // Poor
  }
}
