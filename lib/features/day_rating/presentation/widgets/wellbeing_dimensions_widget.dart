import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Displays PERMA+ wellbeing dimension sliders.
///
/// Each enabled dimension shows a 1–5 slider with an icon, label, and
/// descriptive subtitle. Calls [onChanged] whenever a slider moves.
class WellbeingDimensionsWidget extends StatelessWidget {
  final WellbeingRating rating;
  final List<String> enabledDimensions;
  final ValueChanged<WellbeingRating> onChanged;

  const WellbeingDimensionsWidget({
    super.key,
    required this.rating,
    required this.enabledDimensions,
    required this.onChanged,
  });

  static List<_Dimension> _getDimensions(AppLocalizations l10n) => [
    _Dimension(
      key: 'mood',
      icon: Icons.sentiment_satisfied_alt,
      label: l10n.overallMoodDimension,
      subtitle: l10n.howDidYouFeel,
      color: Colors.purple,
    ),
    _Dimension(
      key: 'energy',
      icon: Icons.bolt,
      label: l10n.energyDimension,
      subtitle: l10n.physicalVitality,
      color: Colors.orange,
    ),
    _Dimension(
      key: 'connection',
      icon: Icons.people,
      label: l10n.connectionDimension,
      subtitle: l10n.socialConnections,
      color: Colors.blue,
    ),
    _Dimension(
      key: 'purpose',
      icon: Icons.track_changes,
      label: l10n.purposeDimension,
      subtitle: l10n.meaningAndPurpose,
      color: Colors.teal,
    ),
    _Dimension(
      key: 'achievement',
      icon: Icons.check_circle_outline,
      label: l10n.achievementDimension,
      subtitle: l10n.accomplishments,
      color: Colors.green,
    ),
    _Dimension(
      key: 'engagement',
      icon: Icons.psychology,
      label: l10n.engagementDimension,
      subtitle: l10n.flowAndAbsorption,
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final visible = _getDimensions(l10n)
        .where((d) => enabledDimensions.contains(d.key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.bar_chart, color: theme.colorScheme.primary, size: 20),
            AppSpacing.horizontalXs,
            Flexible(
              child: Text(
                l10n.wellbeingDimensions,
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
          l10n.permaPlusDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSm,

        // Dimension sliders
        ...visible.map((d) => _DimensionSlider(
              dimension: d,
              value: _valueFor(d.key),
              onChanged: (v) => onChanged(_updatedRating(d.key, v)),
              theme: theme,
            )),
      ],
    );
  }

  int _valueFor(String key) {
    switch (key) {
      case 'mood':
        return rating.mood;
      case 'energy':
        return rating.energy;
      case 'connection':
        return rating.connection;
      case 'purpose':
        return rating.purpose;
      case 'achievement':
        return rating.achievement;
      case 'engagement':
        return rating.engagement;
      default:
        return 0;
    }
  }

  WellbeingRating _updatedRating(String key, int value) {
    switch (key) {
      case 'mood':
        return rating.copyWith(mood: value);
      case 'energy':
        return rating.copyWith(energy: value);
      case 'connection':
        return rating.copyWith(connection: value);
      case 'purpose':
        return rating.copyWith(purpose: value);
      case 'achievement':
        return rating.copyWith(achievement: value);
      case 'engagement':
        return rating.copyWith(engagement: value);
      default:
        return rating;
    }
  }
}

// ── Individual dimension slider ────────────────────────────────────────────

class _DimensionSlider extends StatelessWidget {
  final _Dimension dimension;
  final int value;
  final ValueChanged<int> onChanged;
  final ThemeData theme;

  const _DimensionSlider({
    required this.dimension,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  String _getLabel(AppLocalizations l10n) {
    switch (value) {
      case 1:
        return l10n.ratingPoor;
      case 2:
        return l10n.ratingFair;
      case 3:
        return l10n.ratingGood;
      case 4:
        return l10n.ratingGreat;
      case 5:
        return l10n.ratingExcellent;
      default:
        return l10n.notRated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveValue = value == 0 ? 3.0 : value.toDouble();

    return Padding(
      padding: AppSpacing.paddingVerticalXs,
      child: AppCard.outlined(
        padding: AppSpacing.paddingAllSm,
        color: theme.colorScheme.surface,
        borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: AppRadius.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(dimension.icon, color: dimension.color, size: 18),
                AppSpacing.horizontalXs,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dimension.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dimension.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _scoreColor(value).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    _getLabel(l10n),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _scoreColor(value),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: dimension.color,
                thumbColor: dimension.color,
                inactiveTrackColor: dimension.color.withValues(alpha: 0.2),
                overlayColor: dimension.color.withValues(alpha: 0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: effectiveValue,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),

            // Step labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['1', '2', '3', '4', '5'].map((n) {
                return Text(
                  n,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    switch (score) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// ── Dimension metadata ─────────────────────────────────────────────────────

class _Dimension {
  final String key;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _Dimension({
    required this.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}
