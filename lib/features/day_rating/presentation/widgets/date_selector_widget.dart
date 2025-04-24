import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateSelectorWidget extends ConsumerWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(wizardSelectedDateProvider);
    final theme = ref.watch(themeProvider);
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');

    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Date display with detailed format
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatter.format(selectedDate),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to change date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(ref, -1),
                  tooltip: 'Previous day',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, ref),
                  tooltip: 'Select date',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDate(ref, 1),
                  tooltip: 'Next day',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeDate(WidgetRef ref, int dayOffset) {
    final currentDate = ref.read(wizardSelectedDateProvider);
    final newDate = currentDate.add(Duration(days: dayOffset));

    // Update date
    ref.read(wizardSelectedDateProvider.notifier).updateSelectedDate(
          DateTime(
            newDate.year,
            newDate.month,
            newDate.day,
            currentDate.hour,
            currentDate.minute,
          ),
        );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final currentDate = ref.read(wizardSelectedDateProvider);
    final theme = ref.read(themeProvider);

    final newDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (newDate != null) {
      // Update with new date but preserve time
      ref.read(wizardSelectedDateProvider.notifier).updateSelectedDate(
            DateTime(
              newDate.year,
              newDate.month,
              newDate.day,
              currentDate.hour,
              currentDate.minute,
            ),
          );
    }
  }
}
