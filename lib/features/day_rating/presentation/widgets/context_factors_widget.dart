import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:flutter/material.dart';

/// Widget for capturing contextual factors (Tier 4).
///
/// Covers: sleep hours, sleep quality, exercise, stress level, and custom tags.
class ContextFactorsWidget extends StatefulWidget {
  final ContextualFactors factors;
  final ValueChanged<ContextualFactors> onChanged;

  const ContextFactorsWidget({
    super.key,
    required this.factors,
    required this.onChanged,
  });

  @override
  State<ContextFactorsWidget> createState() => _ContextFactorsWidgetState();
}

class _ContextFactorsWidgetState extends State<ContextFactorsWidget> {
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _update(ContextualFactors updated) => widget.onChanged(updated);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = widget.factors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.tune, color: theme.colorScheme.primary, size: 20),
            AppSpacing.horizontalXs,
            Flexible(
              child: Text(
                'Context Factors',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalXxs,
        Text(
          'Optional context that may influence your mood',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSm,

        // Sleep hours
        _SectionLabel(icon: Icons.bedtime, label: 'Sleep Hours', theme: theme),
        AppSpacing.verticalXxs,
        Row(
          children: [
            Expanded(
              child: Slider(
                value: (f.sleepHours ?? 7.0).clamp(0.0, 12.0),
                min: 0,
                max: 12,
                divisions: 24,
                label:
                    '${(f.sleepHours ?? 7.0).toStringAsFixed(1)} h',
                onChanged: (v) =>
                    _update(f.copyWith(sleepHours: v)),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                '${(f.sleepHours ?? 7.0).toStringAsFixed(1)} h',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),

        AppSpacing.verticalXs,

        // Sleep quality
        _SectionLabel(icon: Icons.star_half, label: 'Sleep Quality', theme: theme),
        AppSpacing.verticalXxs,
        _FiveStepRow(
          value: f.sleepQuality ?? 0,
          activeColor: Colors.indigo,
          theme: theme,
          onChanged: (v) => _update(f.copyWith(sleepQuality: v)),
        ),

        AppSpacing.verticalSm,

        // Exercise
        _SectionLabel(icon: Icons.directions_run, label: 'Exercised Today', theme: theme),
        AppSpacing.verticalXxs,
        Row(
          children: [
            Switch(
              value: f.exercised ?? false,
              onChanged: (v) => _update(f.copyWith(exercised: v)),
            ),
            AppSpacing.horizontalXs,
            Text(
              (f.exercised ?? false) ? 'Yes' : 'No',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        AppSpacing.verticalSm,

        // Stress level
        _SectionLabel(icon: Icons.psychology_alt, label: 'Stress Level', theme: theme),
        AppSpacing.verticalXxs,
        _FiveStepRow(
          value: f.stressLevel ?? 0,
          activeColor: Colors.red,
          theme: theme,
          onChanged: (v) => _update(f.copyWith(stressLevel: v)),
        ),

        AppSpacing.verticalSm,

        // Tags
        _SectionLabel(icon: Icons.label_outline, label: 'Tags', theme: theme),
        AppSpacing.verticalXxs,
        if (f.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: f.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        final updated = List<String>.from(f.tags)
                          ..remove(tag);
                        _update(f.copyWith(tags: updated));
                      },
                      labelStyle: theme.textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        AppSpacing.verticalXxs,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _tagController,
                hint: 'Add a tag (e.g. travel, sick, date night)',
                onSubmitted: (_) => _addTag(),
              ),
            ),
            AppSpacing.horizontalXs,
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add tag',
            ),
          ],
        ),
      ],
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !widget.factors.tags.contains(tag)) {
      final updated = List<String>.from(widget.factors.tags)..add(tag);
      _update(widget.factors.copyWith(tags: updated));
      _tagController.clear();
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        AppSpacing.horizontalXxs,
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A horizontal row of 5 numbered buttons used for quality/stress ratings.
class _FiveStepRow extends StatelessWidget {
  final int value;
  final Color activeColor;
  final ThemeData theme;
  final ValueChanged<int> onChanged;

  const _FiveStepRow({
    required this.value,
    required this.activeColor,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final active = value == n;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(active ? 0 : n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? activeColor.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: active
                      ? activeColor
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  '$n',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: active ? activeColor : theme.colorScheme.onSurface,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
