import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/domain/providers/goal_providers.dart';

class CreateGoalDialog extends ConsumerStatefulWidget {
  const CreateGoalDialog({super.key});

  @override
  ConsumerState<CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends ConsumerState<CreateGoalDialog> {
  DayRatings _selectedCategory = DayRatings.productivity;
  GoalTimeframe _selectedTimeframe = GoalTimeframe.weekly;
  double _targetValue = 3.5;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestedTarget =
        ref.watch(targetSuggestionProvider(_selectedCategory));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.flag, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Create New Goal',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress indicator
            _buildStepIndicator(context),
            const SizedBox(height: 24),

            // Step content
            if (_currentStep == 0) _buildCategoryStep(context),
            if (_currentStep == 1) _buildTimeframeStep(context),
            if (_currentStep == 2) _buildTargetStep(context, suggestedTarget),

            const SizedBox(height: 24),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _currentStep < 2
                      ? () => setState(() => _currentStep++)
                      : () => _createGoal(context),
                  child: Text(_currentStep < 2 ? 'Next' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which area do you want to improve?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...DayRatings.values.map((category) => _buildCategoryOption(
              context,
              category,
              _getCategoryName(category),
              _getCategoryIcon(category),
              _getCategoryColor(category),
            )),
      ],
    );
  }

  Widget _buildCategoryOption(
    BuildContext context,
    DayRatings category,
    String name,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your timeframe',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimeframeOption(
                context,
                GoalTimeframe.weekly,
                'Weekly',
                Icons.calendar_view_week,
                '7 days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeframeOption(
                context,
                GoalTimeframe.monthly,
                'Monthly',
                Icons.calendar_month,
                '~30 days',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeframeOption(
    BuildContext context,
    GoalTimeframe timeframe,
    String name,
    IconData icon,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedTimeframe == timeframe;

    return InkWell(
      onTap: () => setState(() => _selectedTimeframe = timeframe),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetStep(BuildContext context, double suggestedTarget) {
    final theme = Theme.of(context);
    final categoryName = _getCategoryName(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your target',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What average $categoryName score do you want to achieve?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Suggested target banner (Endowed Progress Effect)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Based on your history, we suggest ${suggestedTarget.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _targetValue = suggestedTarget),
                child: const Text('Use'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Target slider
        Center(
          child: Text(
            _targetValue.toStringAsFixed(1),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Slider(
          value: _targetValue,
          min: 1.0,
          max: 5.0,
          divisions: 40,
          label: _targetValue.toStringAsFixed(1),
          onChanged: (value) => setState(() => _targetValue = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1.0', style: theme.textTheme.bodySmall),
            Text('Target Score', style: theme.textTheme.bodySmall),
            Text('5.0', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  void _createGoal(BuildContext context) {
    final goal = _selectedTimeframe == GoalTimeframe.weekly
        ? Goal.weekly(
            category: _selectedCategory,
            targetValue: _targetValue,
          )
        : Goal.monthly(
            category: _selectedCategory,
            targetValue: _targetValue,
          );

    ref.read(goalsLocalDbDataProvider.notifier).addOrUpdateElement(goal);
    Navigator.of(context).pop(goal);
  }

  String _getCategoryName(DayRatings category) {
    switch (category) {
      case DayRatings.social:
        return 'Social';
      case DayRatings.productivity:
        return 'Productivity';
      case DayRatings.sport:
        return 'Sport';
      case DayRatings.food:
        return 'Food';
    }
  }

  IconData _getCategoryIcon(DayRatings category) {
    switch (category) {
      case DayRatings.social:
        return Icons.people;
      case DayRatings.productivity:
        return Icons.work;
      case DayRatings.sport:
        return Icons.fitness_center;
      case DayRatings.food:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(DayRatings category) {
    switch (category) {
      case DayRatings.social:
        return Colors.blue;
      case DayRatings.productivity:
        return Colors.orange;
      case DayRatings.sport:
        return Colors.green;
      case DayRatings.food:
        return Colors.red;
    }
  }
}
