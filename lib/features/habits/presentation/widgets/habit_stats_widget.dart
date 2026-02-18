import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitStatsWidget extends ConsumerWidget {
  const HabitStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeHabits = ref.watch(activeHabitsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (activeHabits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            l10n.habitNoHabits,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: activeHabits.length,
      itemBuilder: (context, index) {
        final habit = activeHabits[index];
        final stats = ref.watch(habitStatsProvider(habit.id));

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Habit header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(habit.icon, color: habit.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Streak row
                Row(
                  children: [
                    _buildStatBox(
                      theme,
                      l10n.habitCurrentStreak,
                      '${stats.currentStreak}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBox(
                      theme,
                      l10n.habitBestStreak,
                      '${stats.bestStreak}',
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBox(
                      theme,
                      l10n.habitTotalCompletions,
                      '${stats.totalCompletions}',
                      Icons.check_circle,
                      habit.color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Completion rates
                Text(
                  l10n.habitCompletionRate,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCompletionBar(
                    theme, l10n.habitLast7Days, stats.completionRate7d, habit.color),
                const SizedBox(height: 6),
                _buildCompletionBar(
                    theme, l10n.habitLast30Days, stats.completionRate30d, habit.color),
                const SizedBox(height: 6),
                _buildCompletionBar(
                    theme, l10n.habitAllTime, stats.completionRateAll, habit.color),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(
      ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBar(
      ThemeData theme, String label, double rate, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${(rate * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
