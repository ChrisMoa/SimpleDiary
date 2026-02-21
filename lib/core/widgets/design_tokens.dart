import 'package:flutter/material.dart';

/// Standardized spacing constants used throughout the app.
///
/// Based on the existing spacing scale found in the codebase:
/// 4, 8, 12, 16, 20, 24, 32, 48
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Pre-built vertical SizedBox instances
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  // Pre-built horizontal SizedBox instances
  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);

  // Common EdgeInsets presets
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalXs =
      EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);
}

/// Standardized border radius values.
///
/// Based on the existing values found in the codebase:
/// 8 (inputs/dropdowns), 12 (most common), 16 (cards), 20 (dialogs/pills)
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);

  static final ShapeBorder shapeSm =
      RoundedRectangleBorder(borderRadius: borderRadiusSm);
  static final ShapeBorder shapeMd =
      RoundedRectangleBorder(borderRadius: borderRadiusMd);
  static final ShapeBorder shapeLg =
      RoundedRectangleBorder(borderRadius: borderRadiusLg);
  static final ShapeBorder shapeXl =
      RoundedRectangleBorder(borderRadius: borderRadiusXl);
}

/// Standardized elevation values.
abstract final class AppElevation {
  static const double flat = 0;
  static const double low = 1;
  static const double medium = 2;
  static const double high = 4;
}
