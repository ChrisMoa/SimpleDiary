import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitsSummarySection extends ConsumerWidget {
  const HabitsSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabits = ref.watch(todayHabitsProvider);
    final todayEntries = ref.watch(todayEntriesProvider);
    final progress = ref.watch(todayProgressProvider);
    final activeHabits = ref.watch(activeHabitsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (activeHabits.isEmpty) return const SizedBox.shrink();

    final completedIds =
        todayEntries.where((e) => e.isCompleted).map((e) => e.habitId).toSet();
    final completedCount =
        todayHabits.where((h) => completedIds.contains(h.id)).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.habitsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount / ${todayHabits.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: progress >= 1.0
                  ? Colors.green
                  : theme.colorScheme.primary,
            ),
          ),
          if (progress >= 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.habitAllHabitsCompleted,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
