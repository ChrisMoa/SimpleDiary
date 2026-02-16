import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/goals/domain/providers/goal_providers.dart';
import 'package:day_tracker/features/goals/presentation/widgets/goal_progress_card.dart';
import 'package:day_tracker/features/goals/presentation/widgets/create_goal_dialog.dart';

class GoalsSection extends ConsumerWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGoals = ref.watch(activeGoalsWithProgressProvider);
    final goalStreak = ref.watch(goalStreakProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with streak and add button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.flag, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Goals',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              if (goalStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '$goalStreak',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showCreateGoalDialog(context),
                tooltip: 'Create New Goal',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),

        // Active goals or empty state
        if (activeGoals.isEmpty)
          _buildEmptyState(context)
        else
          ...activeGoals.map((progress) => GoalProgressCard(
                progress: progress,
                onTap: () => _showGoalDetails(context, progress),
              )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No active goals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set a goal to track your progress and stay motivated',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showCreateGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Set Your First Goal'),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateGoalDialog(),
    );
  }

  void _showGoalDetails(BuildContext context, progress) {
    // Navigate to goal details or show bottom sheet
    // TODO: Implement goal details view
  }
}
