import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_frequency.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitEditDialog extends ConsumerStatefulWidget {
  final Habit? habit; // null = create new

  const HabitEditDialog({super.key, this.habit});

  @override
  ConsumerState<HabitEditDialog> createState() => _HabitEditDialogState();
}

class _HabitEditDialogState extends ConsumerState<HabitEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _iconCodePoint;
  late Color _color;
  late HabitFrequency _frequency;
  late int _targetCount;
  late List<int> _specificDays;
  late int _timesPerWeek;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.habit?.description ?? '');
    _iconCodePoint = widget.habit?.iconCodePoint ?? Icons.check_circle_outline.codePoint;
    _color = widget.habit?.color ?? Colors.green;
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _targetCount = widget.habit?.targetCount ?? 1;
    _specificDays = List<int>.from(widget.habit?.specificDays ?? []);
    _timesPerWeek = widget.habit?.timesPerWeek ?? 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      title: Text(
        isEditing ? l10n.habitEdit : l10n.habitCreateNew,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                AppTextField(
                  controller: _nameController,
                  label: l10n.habitName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.habitNameRequired;
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSm,

                // Description
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.habitDescription,
                  maxLines: 2,
                ),
                AppSpacing.verticalMd,

                // Icon & Color row
                Row(
                  children: [
                    // Icon picker button
                    InkWell(
                      onTap: () => _showIconPicker(context),
                      borderRadius: AppRadius.borderRadiusMd,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Icon(
                          IconData(_iconCodePoint, fontFamily: 'MaterialIcons'),
                          color: _color,
                          size: 28,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    // Color picker button
                    InkWell(
                      onTap: () => _showColorPicker(context),
                      borderRadius: AppRadius.borderRadiusMd,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: Text(
                        l10n.habitIconAndColor,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,

                // Frequency
                Text(
                  l10n.habitFrequency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalXs,
                _buildFrequencySelector(theme, l10n),
                AppSpacing.verticalSm,

                // Specific days selector (shown only for specificDays frequency)
                if (_frequency == HabitFrequency.specificDays)
                  _buildDaySelector(theme, l10n),

                // Times per week (shown only for timesPerWeek frequency)
                if (_frequency == HabitFrequency.timesPerWeek)
                  _buildTimesPerWeekSelector(theme, l10n),

                // Target count
                AppSpacing.verticalSm,
                Row(
                  children: [
                    Text(
                      l10n.habitTargetCount,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          _targetCount > 1 ? () => setState(() => _targetCount--) : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$_targetCount',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _targetCount++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(ThemeData theme, AppLocalizations l10n) {
    final labels = {
      HabitFrequency.daily: l10n.habitFrequencyDaily,
      HabitFrequency.weekdays: l10n.habitFrequencyWeekdays,
      HabitFrequency.weekends: l10n.habitFrequencyWeekends,
      HabitFrequency.specificDays: l10n.habitFrequencySpecificDays,
      HabitFrequency.timesPerWeek: l10n.habitFrequencyTimesPerWeek,
    };

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: HabitFrequency.values.map((freq) {
        final isSelected = freq == _frequency;
        return ChoiceChip(
          label: Text(labels[freq] ?? freq.name),
          selected: isSelected,
          onSelected: (_) => setState(() => _frequency = freq),
          selectedColor: theme.colorScheme.primaryContainer,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaySelector(ThemeData theme, AppLocalizations l10n) {
    final dayNames = [
      l10n.habitDayMon,
      l10n.habitDayTue,
      l10n.habitDayWed,
      l10n.habitDayThu,
      l10n.habitDayFri,
      l10n.habitDaySat,
      l10n.habitDaySun,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.verticalXs,
        Wrap(
          spacing: 6,
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1=Mon, 7=Sun
            final isSelected = _specificDays.contains(weekday);
            return FilterChip(
              label: Text(dayNames[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _specificDays.add(weekday);
                  } else {
                    _specificDays.remove(weekday);
                  }
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimesPerWeekSelector(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          l10n.habitTimesPerWeekLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed:
              _timesPerWeek > 1 ? () => setState(() => _timesPerWeek--) : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$_timesPerWeek',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed:
              _timesPerWeek < 7 ? () => setState(() => _timesPerWeek++) : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showIconPicker(BuildContext context) {
    final theme = Theme.of(context);
    final icons = [
      Icons.check_circle_outline,
      Icons.fitness_center,
      Icons.menu_book,
      Icons.self_improvement,
      Icons.water_drop,
      Icons.bedtime,
      Icons.directions_run,
      Icons.restaurant,
      Icons.code,
      Icons.music_note,
      Icons.brush,
      Icons.phone_disabled,
      Icons.smoking_rooms,
      Icons.local_cafe,
      Icons.pets,
      Icons.eco,
      Icons.favorite,
      Icons.school,
      Icons.work,
      Icons.savings,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        title: Text(
          AppLocalizations.of(context).habitSelectIcon,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final iconData = icons[index];
              final isSelected = iconData.codePoint == _iconCodePoint;
              return InkWell(
                onTap: () {
                  setState(() => _iconCodePoint = iconData.codePoint);
                  Navigator.of(context).pop();
                },
                borderRadius: AppRadius.borderRadiusSm,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: AppRadius.borderRadiusSm,
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        title: Text(
          AppLocalizations.of(context).habitSelectColor,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: _color,
            onColorChanged: (color) => setState(() => _color = color),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
            },
            enableShadesSelection: false,
            width: 36,
            height: 36,
            borderRadius: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).ok,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_frequency == HabitFrequency.specificDays && _specificDays.isEmpty) {
      AppSnackBar.error(context, message: AppLocalizations.of(context).habitSelectAtLeastOneDay);
      return;
    }

    final habit = Habit(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      iconCodePoint: _iconCodePoint,
      colorValue: _color.toARGB32(),
      frequency: _frequency,
      targetCount: _targetCount,
      specificDays: _specificDays,
      timesPerWeek: _timesPerWeek,
      createdAt: widget.habit?.createdAt,
      isArchived: widget.habit?.isArchived ?? false,
    );

    final notifier = ref.read(habitsLocalDbDataProvider.notifier);
    if (isEditing) {
      notifier.addOrUpdateElement(habit);
    } else {
      notifier.addElement(habit);
    }

    Navigator.of(context).pop();
  }
}
