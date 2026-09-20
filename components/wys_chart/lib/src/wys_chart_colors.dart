import 'package:flutter/material.dart';

/// Shared palette for chart widgets. Callers typically map from feature themes.
@immutable
class WysChartColors {
  const WysChartColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.destructive,
    required this.muted,
    required this.grid,
    required this.foreground,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color destructive;
  final Color muted;
  final Color grid;
  final Color foreground;

  /// Default palette aligned with root DESIGN.md / Vercel Token API.
  static const vercel = WysChartColors(
    primary: Color(0xFF171717),
    secondary: Color(0xFF0070F3),
    accent: Color(0xFFF5A623),
    success: Color(0xFF0070F3),
    destructive: Color(0xFFEE0000),
    muted: Color(0xFF888888),
    grid: Color(0xFFEBEBEB),
    foreground: Color(0xFF171717),
  );
}
