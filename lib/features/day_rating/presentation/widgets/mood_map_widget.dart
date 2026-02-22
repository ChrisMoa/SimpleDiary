import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:flutter/material.dart';

/// Interactive 2D mood map based on the Circumplex Model of Affect
/// (Russell, 1980).
///
/// X axis = valence (negative ←→ positive)
/// Y axis = arousal (low energy ↕ high energy)
///
/// The user taps or drags anywhere in the grid to set their current mood.
class MoodMapWidget extends StatefulWidget {
  final MoodPosition? initialPosition;
  final ValueChanged<MoodPosition> onPositionChanged;

  /// Size of the square map canvas. Defaults to filling available width.
  final double? size;

  const MoodMapWidget({
    super.key,
    this.initialPosition,
    required this.onPositionChanged,
    this.size,
  });

  @override
  State<MoodMapWidget> createState() => _MoodMapWidgetState();
}

class _MoodMapWidgetState extends State<MoodMapWidget> {
  /// Current marker position in normalised coordinates:
  /// (0,0) = top-left, (1,1) = bottom-right.
  Offset? _normalised;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _normalised = _moodToNormalised(widget.initialPosition!);
    }
  }

  // ── Coordinate helpers ─────────────────────────────────────────

  /// Convert [MoodPosition] → normalised canvas coordinates.
  Offset _moodToNormalised(MoodPosition mood) => Offset(
        (mood.valence + 1.0) / 2.0, // x: -1..1 → 0..1
        (1.0 - mood.arousal) / 2.0, // y: high arousal (1) → top (0)
      );

  /// Convert normalised canvas coordinates → [MoodPosition].
  MoodPosition _normalisedToMood(Offset n, double canvasSize) => MoodPosition(
        valence: (n.dx * 2.0 - 1.0).clamp(-1.0, 1.0),
        arousal: (1.0 - n.dy * 2.0).clamp(-1.0, 1.0),
        timestamp: DateTime.now(),
      );

  void _handleGesture(Offset localPosition, double canvasSize) {
    final n = Offset(
      (localPosition.dx / canvasSize).clamp(0.0, 1.0),
      (localPosition.dy / canvasSize).clamp(0.0, 1.0),
    );
    setState(() => _normalised = n);
    widget.onPositionChanged(_normalisedToMood(n, canvasSize));
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                'Quick Mood Check',
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
          'Tap where you are on the mood map',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSm,

        // Map
        LayoutBuilder(builder: (context, constraints) {
          final size = widget.size ?? constraints.maxWidth;
          return _buildMap(context, theme, size);
        }),

        // Label below the map
        if (_normalised != null) ...[
          AppSpacing.verticalXs,
          Center(
            child: _MoodLabel(
              mood: _normalisedToMood(_normalised!, 1),
              theme: theme,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMap(BuildContext context, ThemeData theme, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTapDown: (d) => _handleGesture(d.localPosition, size),
        onPanUpdate: (d) => _handleGesture(d.localPosition, size),
        child: CustomPaint(
          size: Size(size, size),
          painter: _MoodMapPainter(
            normalised: _normalised,
            theme: theme,
          ),
        ),
      ),
    );
  }
}

// ── Mood label chip ────────────────────────────────────────────────────────

class _MoodLabel extends StatelessWidget {
  final MoodPosition mood;
  final ThemeData theme;

  const _MoodLabel({required this.mood, required this.theme});

  Color get _color {
    switch (mood.quadrant) {
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
        mood.label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: _color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Custom painter ─────────────────────────────────────────────────────────

class _MoodMapPainter extends CustomPainter {
  final Offset? normalised;
  final ThemeData theme;

  const _MoodMapPainter({this.normalised, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Quadrant background fills
    final quadrants = [
      // HE positive (top-right) – orange/excited
      (Rect.fromLTWH(w / 2, 0, w / 2, h / 2), Colors.orange.withValues(alpha: 0.12)),
      // LE positive (bottom-right) – green/calm
      (Rect.fromLTWH(w / 2, h / 2, w / 2, h / 2), Colors.green.withValues(alpha: 0.12)),
      // HE negative (top-left) – red/anxious
      (Rect.fromLTWH(0, 0, w / 2, h / 2), Colors.red.withValues(alpha: 0.12)),
      // LE negative (bottom-left) – blueGrey/sad
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

    // Quadrant labels
    final labelStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 10,
    );
    final labels = [
      ('Anxious', Offset(w * 0.1, h * 0.06)),
      ('Excited', Offset(w * 0.58, h * 0.06)),
      ('Sad', Offset(w * 0.1, h * 0.88)),
      ('Calm', Offset(w * 0.58, h * 0.88)),
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
    _drawText(canvas, '▲ High Energy', Offset(w / 2 - 36, 2), axisStyle);
    _drawText(canvas, '▼ Low Energy', Offset(w / 2 - 34, h - 14), axisStyle);
    _drawText(canvas, '◀ Unpleasant', Offset(2, h / 2 - 6), axisStyle);
    _drawText(canvas, 'Pleasant ▶', Offset(w - 66, h / 2 - 6), axisStyle);

    // Marker
    if (normalised != null) {
      final markerX = normalised!.dx * w;
      final markerY = normalised!.dy * h;

      // Shadow
      canvas.drawCircle(
        Offset(markerX, markerY),
        12,
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );

      // Fill
      canvas.drawCircle(
        Offset(markerX, markerY),
        10,
        Paint()..color = theme.colorScheme.primary,
      );

      // Outline
      canvas.drawCircle(
        Offset(markerX, markerY),
        10,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = theme.colorScheme.onPrimary
          ..strokeWidth = 2,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_MoodMapPainter old) =>
      old.normalised != normalised || old.theme != theme;
}
