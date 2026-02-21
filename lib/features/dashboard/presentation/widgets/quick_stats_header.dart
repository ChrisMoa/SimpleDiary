import 'package:day_tracker/core/utils/responsive_breakpoints.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:day_tracker/core/navigation/drawer_index_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quick stats header showing today's status, streak, and weekly average
class QuickStatsHeader extends ConsumerWidget {
  const QuickStatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return statsAsync.when(
      loading: () => AppCard.elevated(
        margin: AppSpacing.paddingAllMd,
        padding: AppSpacing.paddingAllXl,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AppCard.elevated(
        margin: AppSpacing.paddingAllMd,
        padding: AppSpacing.paddingAllXl,
        child: Text(AppLocalizations.of(context)!.errorWithMessage(error.toString())),
      ),
      data: (stats) {
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = theme.colorScheme;
        // Use theme colors: primary for done, error for pending
        final statusColor = stats.todayLogged ? colorScheme.primary : colorScheme.error;
        final statusIcon = stats.todayLogged ? Icons.check_circle : Icons.pending;
        final statusText = stats.todayLogged ? l10n.recorded : l10n.pending;

        return AppCard.elevated(
          margin: AppSpacing.paddingAllMd,
          padding: AppSpacing.paddingAllLg,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.today,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(statusIcon, color: statusColor, size: 32),
                  ],
                ),
                AppSpacing.verticalMd,

                // Stats grid
                isDesktop
                    ? Row(
                        children: [
                          Expanded(child: _buildStreakStat(stats.currentStreak, theme, l10n)),
                          AppSpacing.horizontalMd,
                          Expanded(child: _buildAverageStat(stats.weekStats.averageScore, theme, l10n)),
                          AppSpacing.horizontalMd,
                          Expanded(child: _buildStatusStat(statusText, statusColor, theme, l10n)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildStreakStat(stats.currentStreak, theme, l10n),
                          AppSpacing.verticalSm,
                          _buildAverageStat(stats.weekStats.averageScore, theme, l10n),
                          AppSpacing.verticalSm,
                          _buildStatusStat(statusText, statusColor, theme, l10n),
                        ],
                      ),

                // Action button
                if (!stats.todayLogged) ...[
                  AppSpacing.verticalMd,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(selectedDrawerIndexProvider.notifier).state = 3;
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.recordToday),
                      style: ElevatedButton.styleFrom(
                        padding: AppSpacing.paddingVerticalMd,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        );
      },
    );
  }

  Widget _buildStreakStat(int streak, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              AppSpacing.horizontalXs,
              Text(
                '$streak',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Text(
            l10n.dayStreak,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageStat(double average, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 24)),
              AppSpacing.horizontalXs,
              Text(
                average.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Text(
            l10n.weeklyAverage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStat(String status, Color color, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        children: [
          Text(
            status,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          AppSpacing.verticalXxs,
          Text(
            l10n.status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
