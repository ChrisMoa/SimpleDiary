import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
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

    // Adaptive date formatting based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    // Choose appropriate date format based on screen size
    final DateFormat dateFormatter = isSmallScreen
        ? DateFormat('EEE, MMM d') // Compact format for very small screens
        : DateFormat('EEEE, MMMM d, yyyy'); // Full format for larger screens

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: theme.colorScheme.secondaryContainer,
      borderRadius: AppRadius.borderRadiusMd,
      padding: AppSpacing.paddingAllSm,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Tap to change date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation buttons - use Row instead of separate buttons for better spacing
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconButton(
                  context,
                  icon: Icons.chevron_left,
                  onPressed: () => _changeDate(ref, -1),
                  tooltip: 'Previous day',
                  theme: theme,
                ),
                _buildIconButton(
                  context,
                  icon: Icons.calendar_today,
                  onPressed: () => _selectDate(context, ref),
                  tooltip: 'Select date',
                  theme: theme,
                ),
                _buildIconButton(
                  context,
                  icon: Icons.chevron_right,
                  onPressed: () => _changeDate(ref, 1),
                  tooltip: 'Next day',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
    );
  }

  // Helper method to create a consistent icon button with proper sizing for touch
  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: AppSpacing.paddingAllSm,
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
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
