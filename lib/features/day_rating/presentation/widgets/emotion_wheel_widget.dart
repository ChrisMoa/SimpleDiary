import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Emotion selection widget based on the emotion wheel concept.
///
/// Displays a grid of emotion chips. Tapping a chip opens a brief intensity
/// picker (mild / moderate / strong). Supports multi-select.
class EmotionWheelWidget extends StatelessWidget {
  final List<EmotionEntry> selectedEmotions;
  final ValueChanged<List<EmotionEntry>> onChanged;

  const EmotionWheelWidget({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });

  static List<_EmotionGroup> _getGroups(AppLocalizations l10n) => [
    _EmotionGroup(
      label: l10n.positiveEmotions,
      color: Colors.green,
      emotions: const [
        EmotionType.joy,
        EmotionType.gratitude,
        EmotionType.serenity,
        EmotionType.interest,
        EmotionType.hope,
        EmotionType.pride,
        EmotionType.amusement,
        EmotionType.inspiration,
        EmotionType.awe,
        EmotionType.love,
      ],
    ),
    _EmotionGroup(
      label: l10n.negativeEmotions,
      color: Colors.red,
      emotions: const [
        EmotionType.sadness,
        EmotionType.anger,
        EmotionType.fear,
        EmotionType.disgust,
        EmotionType.shame,
        EmotionType.guilt,
        EmotionType.frustration,
        EmotionType.loneliness,
        EmotionType.anxiety,
      ],
    ),
    _EmotionGroup(
      label: l10n.neutralEmotions,
      color: Colors.blueGrey,
      emotions: const [
        EmotionType.neutral,
        EmotionType.surprised,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.emoji_emotions, color: theme.colorScheme.primary, size: 20),
            AppSpacing.horizontalXs,
            Flexible(
              child: Text(
                l10n.selectEmotions,
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
          l10n.howAreYouFeeling,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSm,

        // Groups
        ..._getGroups(l10n).map((group) => _buildGroup(context, theme, group)),
      ],
    );
  }

  Widget _buildGroup(BuildContext context, ThemeData theme, _EmotionGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: group.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalXxs,
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: group.emotions.map((e) => _EmotionChip(
                emotion: e,
                groupColor: group.color,
                entry: _entryFor(e),
                onTap: () => _onChipTap(context, e, group.color),
              )).toList(),
        ),
        AppSpacing.verticalSm,
      ],
    );
  }

  EmotionEntry? _entryFor(EmotionType emotion) {
    try {
      return selectedEmotions.firstWhere((e) => e.emotion == emotion);
    } catch (_) {
      return null;
    }
  }

  void _onChipTap(BuildContext context, EmotionType emotion, Color color) {
    final existing = _entryFor(emotion);
    if (existing != null) {
      // Already selected → show intensity picker or deselect
      _showIntensityDialog(context, emotion, color, existing.intensity);
    } else {
      // Not selected → add with default intensity 1
      _addOrUpdate(EmotionEntry(emotion: emotion, intensity: 1));
    }
  }

  void _showIntensityDialog(
    BuildContext context,
    EmotionType emotion,
    Color color,
    int current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('How ${_formatName(emotion)} do you feel?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IntensityOption(
              label: l10n.intensityMild,
              intensity: 1,
              color: color,
              selected: current == 1,
              onTap: () {
                _addOrUpdate(EmotionEntry(emotion: emotion, intensity: 1));
                Navigator.pop(ctx);
              },
            ),
            _IntensityOption(
              label: l10n.intensityModerate,
              intensity: 2,
              color: color,
              selected: current == 2,
              onTap: () {
                _addOrUpdate(EmotionEntry(emotion: emotion, intensity: 2));
                Navigator.pop(ctx);
              },
            ),
            _IntensityOption(
              label: l10n.intensityStrong,
              intensity: 3,
              color: color,
              selected: current == 3,
              onTap: () {
                _addOrUpdate(EmotionEntry(emotion: emotion, intensity: 3));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _remove(emotion);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _addOrUpdate(EmotionEntry entry) {
    final updated = List<EmotionEntry>.from(selectedEmotions);
    final idx = updated.indexWhere((e) => e.emotion == entry.emotion);
    if (idx >= 0) {
      updated[idx] = entry;
    } else {
      updated.add(entry);
    }
    onChanged(updated);
  }

  void _remove(EmotionType emotion) {
    onChanged(selectedEmotions.where((e) => e.emotion != emotion).toList());
  }

  static String _formatName(EmotionType e) {
    final n = e.name;
    return n[0].toUpperCase() + n.substring(1);
  }
}

// ── Emotion chip ───────────────────────────────────────────────────────────

class _EmotionChip extends StatelessWidget {
  final EmotionType emotion;
  final Color groupColor;
  final EmotionEntry? entry;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.groupColor,
    required this.entry,
    required this.onTap,
  });

  bool get _selected => entry != null;

  String get _label {
    final name = emotion.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _selected
              ? groupColor.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _selected
                ? groupColor.withValues(alpha: 0.8)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _selected ? groupColor : theme.colorScheme.onSurface,
                  fontWeight:
                      _selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (_selected && entry != null) ...[
              AppSpacing.horizontalXxs,
              _IntensityDots(intensity: entry!.intensity, color: groupColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Intensity dots ─────────────────────────────────────────────────────────

class _IntensityDots extends StatelessWidget {
  final int intensity;
  final Color color;

  const _IntensityDots({required this.intensity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < intensity
                ? color
                : color.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}

// ── Intensity option row ───────────────────────────────────────────────────

class _IntensityOption extends StatelessWidget {
  final String label;
  final int intensity;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _IntensityOption({
    required this.label,
    required this.intensity,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      selectedColor: color,
      title: Text(label),
      leading: _IntensityDots(intensity: intensity, color: color),
      trailing: selected ? Icon(Icons.check, color: color, size: 16) : null,
      onTap: onTap,
    );
  }
}

// ── Emotion group metadata ─────────────────────────────────────────────────

class _EmotionGroup {
  final String label;
  final Color color;
  final List<EmotionType> emotions;

  const _EmotionGroup({
    required this.label,
    required this.color,
    required this.emotions,
  });
}
