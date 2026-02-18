import 'package:day_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitGridWidget extends ConsumerWidget {
  const HabitGridWidget({super.key});

  static const int _daysPerWeek = 7;
  static const double _cellSize = 14.0;
  static const double _cellSpacing = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridData = ref.watch(habitGridDataProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (gridData.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitContributionGrid,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Month labels
          _buildMonthLabels(context, theme, gridData),
          const SizedBox(height: 4),
          // Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Most recent on the right
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day-of-week labels
                _buildDayLabels(theme, l10n),
                const SizedBox(width: 4),
                // Grid cells
                _buildGrid(theme, gridData),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          _buildLegend(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.grid_on,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            l10n.habitNoHabits,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthLabels(
      BuildContext context, ThemeData theme, List<HabitGridDay> gridData) {
    if (gridData.isEmpty) return const SizedBox.shrink();

    // Build month labels aligned to approximate grid positions
    final months = <String>[];
    String? lastMonth;
    for (int i = 0; i < gridData.length; i += 7) {
      final date = gridData[i].date;
      final monthKey = '${date.year}-${date.month}';
      if (monthKey != lastMonth) {
        months.add(_monthAbbrev(date.month));
        lastMonth = monthKey;
      } else {
        months.add('');
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          children: months.map((label) {
            return SizedBox(
              width: _cellSize + _cellSpacing,
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDayLabels(ThemeData theme, AppLocalizations l10n) {
    final labels = ['', l10n.habitDayMon, '', l10n.habitDayWed, '', l10n.habitDayFri, ''];
    return Column(
      children: labels.map((label) {
        return SizedBox(
          height: _cellSize + _cellSpacing,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid(ThemeData theme, List<HabitGridDay> gridData) {
    // Organize into weeks (columns)
    final List<List<HabitGridDay>> weeks = [];
    for (int i = 0; i < gridData.length; i += _daysPerWeek) {
      final end = (i + _daysPerWeek > gridData.length)
          ? gridData.length
          : i + _daysPerWeek;
      weeks.add(gridData.sublist(i, end));
    }

    final baseColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) {
        return Column(
          children: week.map((day) {
            return Padding(
              padding: const EdgeInsets.all(_cellSpacing / 2),
              child: Tooltip(
                message:
                    '${day.date.day}.${day.date.month}.${day.date.year}: ${(day.completionRatio * 100).round()}%',
                child: Container(
                  width: _cellSize,
                  height: _cellSize,
                  decoration: BoxDecoration(
                    color: day.completionRatio == 0.0
                        ? emptyColor
                        : baseColor.withValues(
                            alpha: 0.2 + (day.completionRatio * 0.8)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(ThemeData theme, AppLocalizations l10n) {
    final baseColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    final levels = [0.0, 0.25, 0.5, 0.75, 1.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.habitLess,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        ...levels.map((level) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: level == 0.0
                    ? emptyColor
                    : baseColor.withValues(alpha: 0.2 + (level * 0.8)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          l10n.habitMore,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _monthAbbrev(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
