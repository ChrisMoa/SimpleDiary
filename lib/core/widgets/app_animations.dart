import 'dart:ui';

import 'package:day_tracker/core/widgets/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ─── Page Transitions ────────────────────────────────────────────────────────

/// Custom page route with a combined fade + slide transition.
///
/// Drop-in replacement for [MaterialPageRoute]:
/// ```dart
/// Navigator.of(context).push(AppPageRoute(builder: (_) => MyPage()));
/// ```
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

// ─── Staggered List Item ─────────────────────────────────────────────────────

/// Wraps a child with a staggered slide + fade entrance animation.
///
/// ```dart
/// AnimatedListItem(index: 2, child: MyCard());
/// ```
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
  });

  final int index;
  final Widget child;

  /// Delay between successive items (multiplied by [index]).
  final Duration baseDelay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final totalDelay = baseDelay * index;
    return _DelayedFadeSlide(
      delay: totalDelay,
      duration: duration,
      child: child,
    );
  }
}

class _DelayedFadeSlide extends StatefulWidget {
  const _DelayedFadeSlide({
    required this.delay,
    required this.duration,
    required this.child,
  });

  final Duration delay;
  final Duration duration;
  final Widget child;

  @override
  State<_DelayedFadeSlide> createState() => _DelayedFadeSlideState();
}

class _DelayedFadeSlideState extends State<_DelayedFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(curved);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

// ─── Animated Counter ────────────────────────────────────────────────────────

/// Smoothly animates a numeric value with a counting effect.
///
/// ```dart
/// AnimatedCounter(value: 42, style: theme.textTheme.headlineMedium)
/// AnimatedCounter(value: 3.8, decimalPlaces: 1, style: style)
/// ```
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.decimalPlaces = 0,
    this.duration = const Duration(milliseconds: 800),
    this.prefix = '',
    this.suffix = '',
  });

  final double value;
  final TextStyle? style;
  final int decimalPlaces;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final text = decimalPlaces > 0
            ? animatedValue.toStringAsFixed(decimalPlaces)
            : animatedValue.toInt().toString();
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

// ─── Animated Progress Bar ───────────────────────────────────────────────────

/// A themed, animated progress bar with gradient fill and rounded caps.
///
/// ```dart
/// AnimatedProgressBar(value: 0.75, color: Colors.green)
/// ```
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 10,
    this.duration = const Duration(milliseconds: 800),
    this.borderRadius,
  });

  /// Progress value between 0.0 and 1.0.
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final Duration duration;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Stack(
          children: [
            // Background track
            Container(
              height: height,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: effectiveRadius,
              ),
            ),
            // Animated fill
            FractionallySizedBox(
              widthFactor: animatedValue,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveColor.withValues(alpha: 0.7),
                      effectiveColor,
                    ],
                  ),
                  borderRadius: effectiveRadius,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Tap Scale Wrapper ───────────────────────────────────────────────────────

/// Adds a subtle press-down scale effect to any interactive widget.
///
/// ```dart
/// TapScaleWrapper(onTap: () => ..., child: MyCard())
/// ```
class TapScaleWrapper extends StatefulWidget {
  const TapScaleWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;

  @override
  State<TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<TapScaleWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// ─── Shimmer Placeholder ─────────────────────────────────────────────────────

/// A shimmer skeleton placeholder that matches the shape of content.
///
/// ```dart
/// ShimmerPlaceholder(width: 200, height: 20)
/// ShimmerPlaceholder(width: double.infinity, height: 120, borderRadius: AppRadius.borderRadiusLg)
/// ```
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surfaceContainerHighest,
      highlightColor: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
        ),
      ),
    );
  }
}

/// A shimmer loading card that mimics the shape of an [AppCard].
///
/// ```dart
/// ShimmerCard(height: 120)
/// ShimmerCard(height: 200, child: Column(...)) // custom skeleton layout
/// ```
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 120,
    this.margin,
    this.child,
  });

  final double height;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: margin ?? AppSpacing.paddingAllMd,
      child: Shimmer.fromColors(
        baseColor: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerHighest,
        highlightColor: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.borderRadiusLg,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Glass Container ─────────────────────────────────────────────────────────

/// A frosted-glass container using [BackdropFilter] and [ImageFilter.blur].
///
/// ```dart
/// GlassContainer(
///   borderRadius: AppRadius.borderRadiusXl,
///   child: Padding(padding: AppSpacing.paddingAllXl, child: content),
/// )
/// ```
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.blur = 12.0,
    this.opacity = 0.7,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? AppRadius.borderRadiusXl;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: opacity),
            borderRadius: effectiveRadius,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Page Background Gradient ────────────────────────────────────────────────

/// A subtle gradient overlay for page backgrounds.
///
/// Wraps the page body with a gradient from `primaryContainer` (15% opacity)
/// fading to transparent, covering the top 30% of the page.
///
/// ```dart
/// PageGradientBackground(child: CustomScrollView(...))
/// ```
class PageGradientBackground extends StatelessWidget {
  const PageGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.3,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
