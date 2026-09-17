import 'package:flutter/material.dart';

/// Exact color palette from Google Stitch Design System (DESIGN.md)
abstract class AppColors {
  // Canvas & Background
  static const Color background = Color(0xFFF8FAF7);
  static const Color canvas = Color(0xFFF9FBF8);
  static const Color surface = Color(0xFFF8FAF7);
  static const Color surfaceDim = Color(0xFFD8DBD8);
  static const Color surfaceBright = Color(0xFFF8FAF7);

  // Surface Containers
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Clean white card surface
  static const Color surfaceContainerLow = Color(0xFFF2F4F1);
  static const Color surfaceContainer = Color(0xFFECEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E6);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E0);

  // Primary & Forest Tones
  static const Color primary = Color(0xFF012D1D);
  static const Color primaryContainer = Color(0xFF1B4332);
  static const Color primaryAccent = Color(0xFF40916C);
  static const Color primaryAccentSecondary = Color(0xFF52B788);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF86AF99);
  static const Color inversePrimary = Color(0xFFA5D0B9);

  // Secondary & Botanical Greens
  static const Color secondary = Color(0xFF116C4A);
  static const Color secondaryContainer = Color(0xFFA1F4C8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1B724F);

  // Outlines & Borders
  static const Color outline = Color(0xFF717973);
  static const Color outlineVariant = Color(0xFFC1C8C2);
  static const Color structuralBorder = Color(0xFFE3EAE1);

  // Text Colors
  static const Color onSurface = Color(0xFF191C1B);
  static const Color onSurfaceVariant = Color(0xFF414844);
  static const Color textSecondary = Color(0xFF526058);

  // Semantic & Epistemic Tags
  // Measured / Verified Data
  static const Color measuredBg = Color(0xFFD8F3DC);
  static const Color measuredBorder = Color(0xFFB7E4C7);
  static const Color measuredText = Color(0xFF2D6A4F);
  static const Color measuredDot = Color(0xFF2D6A4F);

  // AI Estimated / Predictive Data
  static const Color aiEstimateBg = Color(0xFFFFF3CD);
  static const Color aiEstimateBorder = Color(0xFFFFE69C);
  static const Color aiEstimateText = Color(0xFFB07D00);
  static const Color aiEstimateDot = Color(0xFFB07D00);

  // Error & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Shadows
  static const Color cardShadow = Color(0x0A1B4332); // rgba(27,67,50,0.04)
  static const Color activeCardShadow = Color(0x141B4332); // rgba(27,67,50,0.08)
  static const Color buttonShadow = Color(0x3B40916C); // rgba(64,145,108,0.25)
}
