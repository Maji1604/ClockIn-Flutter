import 'package:flutter/material.dart';

/// Optimized color system for ClockIn HRMS
/// Focus: Dark Blue, White, Black for professional, clean design
class AppColors {
  // Private constructor
  AppColors._();
  // === CORE BRAND COLORS ===
  // Brand Blue (primary)
  static const Color primary = Color(0xFF0052CC); // deep brand blue
  static const Color primaryLight = Color(0xFF2F6FED);
  static const Color primaryDark = Color(0xFF003A99);

  // Accent / Success
  static const Color accent = Color(0xFF16A34A); // green success accent
  static const Color accentLight = Color(0xFF86efac);

  // === NEUTRAL COLORS ===
  // Pure surfaces
  static const Color surface = Color(0xFFffffff);
  static const Color surfaceLight = Color(0xFFf7fafc);
  static const Color surfaceDark = Color(0xFF1a202c);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1a202c);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textOnPrimary = Color(0xFFffffff);

  // === STATUS COLORS ===
  static const Color success = accent;
  static const Color successLight = Color(0xFFd1fae5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // === BORDER & DIVIDER ===
  static const Color border = Color(0xFFe2e8f0);
  static const Color borderLight = Color(0xFFf1f5f9);
  static const Color divider = Color(0xFFe2e8f0);

  // === INTERACTIVE STATES ===
  static const Color hover = Color(0xFFf7fafc);
  static const Color pressed = Color(0xFFedf2f7);
  static const Color focus = Color(0xFF63b3ed);

  // === GRADIENTS ===
  static const List<Color> primaryGradient = [primary, primaryLight];

  static const List<Color> accentGradient = [accent, accentLight];

  static const List<Color> successGradient = [success, successLight];

  // === SEMANTIC COLORS ===
  // For backward compatibility and specific use cases
  static const Color background = surfaceLight;
  static const Color backgroundDark = surfaceDark;
  static const Color textHint = textTertiary;
  static const Color textDisabled = Color(0xFFa0aec0);
  static const Color textOnSecondary = textPrimary;

  // === UTILITY METHODS ===

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get appropriate text color for background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textOnPrimary;
  }

  /// Get hover color for any base color
  static Color getHoverColor(Color baseColor) {
    return Color.alphaBlend(Colors.black.withValues(alpha: 0.04), baseColor);
  }

  /// Get pressed color for any base color
  static Color getPressedColor(Color baseColor) {
    return Color.alphaBlend(Colors.black.withValues(alpha: 0.08), baseColor);
  }
}
