import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Read-only display of a mood position on the Russell Circumplex Model.
///
/// Two display modes:
/// - [MoodQuadrantDisplaySize.normal]: Full-width grid with axis labels and
///   mood label chip below. Suitable for detail pages.
/// - [MoodQuadrantDisplaySize.compact]: Small square (default 60×60) showing
///   only the quadrant grid and marker. Suitable for list cards.
enum MoodQuadrantDisplaySize { normal, compact }

class MoodQuadrantDisplayWidget extends StatelessWidget {
  final MoodPosition position;
  final MoodQuadrantDisplaySize displaySize;

  /// Only used when [displaySize] is [MoodQuadrantDisplaySize.compact].
  final double compactSize;

  const MoodQuadrantDisplayWidget({
    super.key,
    required this.position,
    this.displaySize = MoodQuadrantDisplaySize.normal,
    this.compactSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (displaySize == MoodQuadrantDisplaySize.compact) {
      return _buildCompact(context);
    }
    return _buildNormal(context);
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: compactSize,
      height: compactSize,
      child: CustomPaint(
        size: Size(compactSize, compactSize),
        painter: _MoodQuadrantPainter(
          position: position,
          theme: theme,
          compact: true,
        ),
      ),
    );
  }

  Widget _buildNormal(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.mood, color: theme.colorScheme.primary, size: 20),
            AppSpacing.horizontalXs,
            Flexible(
              child: Text(
                l10n.moodQuadrant,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSm,

        // Map
        LayoutBuilder(builder: (context, constraints) {
          final size = constraints.maxWidth;
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              size: Size(size, size),
              painter: _MoodQuadrantPainter(
                position: position,
                theme: theme,
                compact: false,
                highEnergyLabel: '▲ ${l10n.highEnergy}',
                lowEnergyLabel: '▼ ${l10n.lowEnergy}',
                pleasantLabel: '${l10n.pleasant} ▶',
                unpleasantLabel: '◀ ${l10n.unpleasant}',
                quadrantLabels: _getQuadrantLabels(l10n),
              ),
            ),
          );
        }),

        // Mood label chip
        AppSpacing.verticalXs,
        Center(
          child: _MoodDisplayLabel(
            position: position,
            theme: theme,
            l10n: l10n,
          ),
        ),
      ],
    );
  }

  Map<MoodQuadrant, String> _getQuadrantLabels(AppLocalizations l10n) => {
        MoodQuadrant.highEnergyNegative: l10n.moodAnxious,
        MoodQuadrant.highEnergyPositive: l10n.moodExcited,
        MoodQuadrant.lowEnergyNegative: l10n.moodSad,
        MoodQuadrant.lowEnergyPositive: l10n.moodCalm,
      };
}

// ── Mood label chip (read-only) ────────────────────────────────────────────

class _MoodDisplayLabel extends StatelessWidget {
  final MoodPosition position;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _MoodDisplayLabel({
    required this.position,
    required this.theme,
    required this.l10n,
  });

  Color get _color => quadrantColor(position.quadrant);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        localizedMoodLabel(position, l10n),
        style: theme.textTheme.labelLarge?.copyWith(
          color: _color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Custom painter ─────────────────────────────────────────────────────────

class _MoodQuadrantPainter extends CustomPainter {
  final MoodPosition position;
  final ThemeData theme;
  final bool compact;
  final String? highEnergyLabel;
  final String? lowEnergyLabel;
  final String? pleasantLabel;
  final String? unpleasantLabel;
  final Map<MoodQuadrant, String>? quadrantLabels;

  const _MoodQuadrantPainter({
    required this.position,
    required this.theme,
    required this.compact,
    this.highEnergyLabel,
    this.lowEnergyLabel,
    this.pleasantLabel,
    this.unpleasantLabel,
    this.quadrantLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Quadrant background fills
    final quadrants = [
      (Rect.fromLTWH(w / 2, 0, w / 2, h / 2), Colors.orange.withValues(alpha: 0.12)),
      (Rect.fromLTWH(w / 2, h / 2, w / 2, h / 2), Colors.green.withValues(alpha: 0.12)),
      (Rect.fromLTWH(0, 0, w / 2, h / 2), Colors.red.withValues(alpha: 0.12)),
      (Rect.fromLTWH(0, h / 2, w / 2, h / 2), Colors.blueGrey.withValues(alpha: 0.12)),
    ];

    final fillPaint = Paint()..style = PaintingStyle.fill;
    for (final (rect, color) in quadrants) {
      fillPaint.color = color;
      canvas.drawRect(rect, fillPaint);
    }

    // Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.colorScheme.outline.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);

    // Axis lines
    final axisPaint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), axisPaint);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), axisPaint);

    // Labels (normal mode only)
    if (!compact && quadrantLabels != null) {
      final labelStyle = TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 10,
      );
      final labels = [
        (quadrantLabels![MoodQuadrant.highEnergyNegative]!, Offset(w * 0.1, h * 0.06)),
        (quadrantLabels![MoodQuadrant.highEnergyPositive]!, Offset(w * 0.58, h * 0.06)),
        (quadrantLabels![MoodQuadrant.lowEnergyNegative]!, Offset(w * 0.1, h * 0.88)),
        (quadrantLabels![MoodQuadrant.lowEnergyPositive]!, Offset(w * 0.58, h * 0.88)),
      ];
      for (final (text, offset) in labels) {
        _drawText(canvas, text, offset, labelStyle);
      }

      // Axis labels
      final axisStyle = TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      );
      if (highEnergyLabel != null) {
        _drawText(canvas, highEnergyLabel!, Offset(w / 2 - 36, 2), axisStyle);
      }
      if (lowEnergyLabel != null) {
        _drawText(canvas, lowEnergyLabel!, Offset(w / 2 - 34, h - 14), axisStyle);
      }
      if (unpleasantLabel != null) {
        _drawText(canvas, unpleasantLabel!, Offset(2, h / 2 - 6), axisStyle);
      }
      if (pleasantLabel != null) {
        _drawText(canvas, pleasantLabel!, Offset(w - 66, h / 2 - 6), axisStyle);
      }
    }

    // Convert mood position to canvas coordinates
    final markerX = ((position.valence + 1.0) / 2.0) * w;
    final markerY = ((1.0 - position.arousal) / 2.0) * h;
    final markerRadius = compact ? 5.0 : 10.0;
    final shadowRadius = compact ? 7.0 : 12.0;

    // Shadow
    canvas.drawCircle(
      Offset(markerX, markerY),
      shadowRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Fill
    canvas.drawCircle(
      Offset(markerX, markerY),
      markerRadius,
      Paint()..color = theme.colorScheme.primary,
    );

    // Outline
    canvas.drawCircle(
      Offset(markerX, markerY),
      markerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = theme.colorScheme.onPrimary
        ..strokeWidth = compact ? 1.5 : 2,
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_MoodQuadrantPainter old) =>
      old.position.valence != position.valence ||
      old.position.arousal != position.arousal ||
      old.theme != theme ||
      old.compact != compact;
}

// ── Shared helpers ─────────────────────────────────────────────────────────

/// Returns the semantic color for a given [MoodQuadrant].
Color quadrantColor(MoodQuadrant quadrant) {
  switch (quadrant) {
    case MoodQuadrant.highEnergyPositive:
      return Colors.orange;
    case MoodQuadrant.lowEnergyPositive:
      return Colors.green;
    case MoodQuadrant.highEnergyNegative:
      return Colors.red;
    case MoodQuadrant.lowEnergyNegative:
      return Colors.blueGrey;
  }
}

/// Returns a localized label for the mood position.
String localizedMoodLabel(MoodPosition mood, AppLocalizations l10n) {
  if (mood.arousal > 0.5 && mood.valence > 0.5) return l10n.moodExcited;
  if (mood.arousal > 0.5 && mood.valence < -0.5) return l10n.moodAnxious;
  if (mood.arousal < -0.5 && mood.valence > 0.5) return l10n.moodCalm;
  if (mood.arousal < -0.5 && mood.valence < -0.5) return l10n.moodSad;
  if (mood.valence > 0.3) return l10n.moodPleasant;
  if (mood.valence < -0.3) return l10n.moodUnpleasant;
  return l10n.moodNeutral;
}
