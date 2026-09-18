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
}
