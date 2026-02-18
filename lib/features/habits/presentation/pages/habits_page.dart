import 'package:day_tracker/features/habits/presentation/widgets/habit_checklist_widget.dart';
import 'package:day_tracker/features/habits/presentation/widgets/habit_edit_dialog.dart';
import 'package:day_tracker/features/habits/presentation/widgets/habit_grid_widget.dart';
import 'package:day_tracker/features/habits/presentation/widgets/habit_stats_widget.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: TabBar(
          tabs: [
            Tab(text: l10n.habitsToday, icon: const Icon(Icons.today)),
            Tab(text: l10n.habitsGrid, icon: const Icon(Icons.grid_on)),
            Tab(text: l10n.habitsStats, icon: const Icon(Icons.bar_chart)),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
        ),
        body: const TabBarView(
          children: [
            // Today tab
            SingleChildScrollView(
              child: HabitChecklistWidget(),
            ),
            // Grid tab
            SingleChildScrollView(
              child: HabitGridWidget(),
            ),
            // Stats tab
            HabitStatsWidget(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const HabitEditDialog(),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
