import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/domain/providers/goal_providers.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final suggestedTarget =
        ref.watch(targetSuggestionProvider(_selectedCategory));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.flag, color: theme.colorScheme.primary),
                AppSpacing.horizontalXs,
                Text(
                  l10n.goalCreateNew,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalXs,

            // Progress indicator
            _buildStepIndicator(context),
            AppSpacing.verticalXl,

            // Step content
            if (_currentStep == 0) _buildCategoryStep(context),
            if (_currentStep == 1) _buildTimeframeStep(context),
            if (_currentStep == 2) _buildTargetStep(context, suggestedTarget),

            AppSpacing.verticalXl,

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Text(l10n.back),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _currentStep < 2
                      ? () => setState(() => _currentStep++)
                      : () => _createGoal(context),
                  child: Text(_currentStep < 2 ? l10n.next : l10n.goalCreate),
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goalSelectCategory,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalMd,
        ...DayRatings.values.map((category) => _buildCategoryOption(
              context,
              category,
              _getCategoryName(category, l10n),
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
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          padding: AppSpacing.paddingAllSm,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: AppRadius.borderRadiusMd,
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              AppSpacing.horizontalSm,
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goalSelectTimeframe,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalMd,
        Row(
          children: [
            Expanded(
              child: _buildTimeframeOption(
                context,
                GoalTimeframe.weekly,
                l10n.goalWeekly,
                Icons.calendar_view_week,
                l10n.goalWeeklyDays,
              ),
            ),
            AppSpacing.horizontalSm,
            Expanded(
              child: _buildTimeframeOption(
                context,
                GoalTimeframe.monthly,
                l10n.goalMonthly,
                Icons.calendar_month,
                l10n.goalMonthlyDays,
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
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        padding: AppSpacing.paddingAllMd,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppRadius.borderRadiusMd,
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
            AppSpacing.verticalXs,
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
    final l10n = AppLocalizations.of(context);
    final categoryName = _getCategoryName(_selectedCategory, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goalSetTarget,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          l10n.goalTargetHint(categoryName),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalXl,

        // Suggested target banner (Endowed Progress Effect)
        Container(
          padding: AppSpacing.paddingAllSm,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: AppRadius.borderRadiusMd,
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
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  l10n.goalSuggestedTarget(suggestedTarget.toStringAsFixed(1)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _targetValue = suggestedTarget),
                child: Text(l10n.goalUseSuggestion),
              ),
            ],
          ),
        ),
        AppSpacing.verticalXl,

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
          semanticFormatterCallback: (v) =>
              '${v.toStringAsFixed(1)} / 5.0',
          onChanged: (value) => setState(() => _targetValue = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1.0', style: theme.textTheme.bodySmall),
            Text(l10n.goalTargetLabel, style: theme.textTheme.bodySmall),
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

  String _getCategoryName(DayRatings category, AppLocalizations l10n) {
    switch (category) {
      case DayRatings.social:
        return l10n.ratingSocial;
      case DayRatings.productivity:
        return l10n.ratingProductivity;
      case DayRatings.sport:
        return l10n.ratingSport;
      case DayRatings.food:
        return l10n.ratingFood;
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
