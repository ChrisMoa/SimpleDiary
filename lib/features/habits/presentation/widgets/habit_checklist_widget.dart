import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/features/habits/presentation/widgets/habit_edit_dialog.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitChecklistWidget extends ConsumerWidget {
  const HabitChecklistWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabits = ref.watch(todayHabitsProvider);
    final todayEntries = ref.watch(todayEntriesProvider);
    final progress = ref.watch(todayProgressProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (todayHabits.isEmpty) {
      return _buildEmptyState(context, l10n, theme);
    }

    final completedIds =
        todayEntries.where((e) => e.isCompleted).map((e) => e.habitId).toSet();

    return Column(
      children: [
        // Progress header
        _buildProgressHeader(
            context, theme, l10n, progress, completedIds.length, todayHabits.length),
        AppSpacing.verticalXs,
        // Habit list
        ...todayHabits.asMap().entries.map((entry) {
          final habit = entry.value;
          final isCompleted = completedIds.contains(habit.id);
          return AnimatedListItem(
            index: entry.key,
            child: _HabitChecklistItem(
              habit: habit,
              isCompleted: isCompleted,
              onToggle: () => _toggleHabit(ref, habit, todayEntries, isCompleted),
              onEdit: () => _showEditDialog(context, habit),
              onDelete: () => _confirmDelete(context, ref, habit, l10n),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProgressHeader(BuildContext context, ThemeData theme,
      AppLocalizations l10n, double progress, int completed, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  color: progress >= 1.0
                      ? Colors.green.shade600
                      : theme.colorScheme.primary,
                ),
                Text(
                  '$completed/$total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.habitTodayProgress,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                progress >= 1.0 ? l10n.habitAllHabitsCompleted : '$completed / $total ${l10n.habitCompleted}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: AppSpacing.paddingAllMd,
      padding: AppSpacing.paddingAllXl,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          AppSpacing.verticalSm,
          Text(
            l10n.habitNoHabits,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalXxs,
          Text(
            l10n.habitNoHabitsDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalMd,
          FilledButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const HabitEditDialog(),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.habitCreateFirst),
          ),
        ],
      ),
    );
  }

  void _toggleHabit(WidgetRef ref, Habit habit, List<HabitEntry> todayEntries,
      bool isCompleted) {
    final notifier = ref.read(habitEntriesLocalDbDataProvider.notifier);
    final existing =
        todayEntries.where((e) => e.habitId == habit.id).firstOrNull;

    if (existing != null) {
      final updated = existing.copyWith(isCompleted: !isCompleted);
      notifier.addOrUpdateElement(updated);
    } else {
      final now = DateTime.now();
      final entry = HabitEntry(
        habitId: habit.id,
        date: DateTime(now.year, now.month, now.day),
        isCompleted: true,
      );
      notifier.addElement(entry);
    }
  }

  void _showEditDialog(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (_) => HabitEditDialog(habit: habit),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Habit habit, AppLocalizations l10n) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.habitDeleteTitle,
      content: l10n.habitDeleteConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed) {
      // Delete all entries for this habit
      final entries = ref.read(habitEntriesLocalDbDataProvider);
      final habitEntries =
          entries.where((e) => e.habitId == habit.id).toList();
      for (final entry in habitEntries) {
        ref
            .read(habitEntriesLocalDbDataProvider.notifier)
            .deleteElement(entry);
      }
      // Delete the habit
      ref.read(habitsLocalDbDataProvider.notifier).deleteElement(habit);
    }
  }
}

class _HabitChecklistItem extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitChecklistItem({
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isCompleted
          ? habit.color.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.08)
          : null,
      borderColor: isCompleted
          ? habit.color.withValues(alpha: 0.3)
          : null,
      borderRadius: AppRadius.borderRadiusMd,
      onTap: onToggle,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(habit.icon, color: habit.color, size: 22),
              ),
              AppSpacing.horizontalSm,
              // Name & description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (habit.description.isNotEmpty)
                      Text(
                        habit.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Popup menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: theme.colorScheme.onSurface),
                        AppSpacing.horizontalXs,
                        Text(AppLocalizations.of(context).edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                        AppSpacing.horizontalXs,
                        Text(
                          AppLocalizations.of(context).delete,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Checkbox
              Checkbox(
                value: isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: habit.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
    );
  }
}
