import 'package:flutter/material.dart';
import 'package:wys_chart/wys_chart.dart';

/// 数据分析页设计 token（ui-ux-pro-max Analytics Dashboard）。
abstract final class AnalyticsTheme {
  static const Color primary = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFD97706);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF1E3A8A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFDBEAFE);
  static const Color destructive = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);

  static const double cardRadius = 14;
  static const double gridGap = 8;

  static const WysChartColors chartColors = WysChartColors(
    primary: primary,
    secondary: secondary,
    accent: accent,
    success: success,
    destructive: destructive,
    muted: muted,
    grid: border,
    foreground: foreground,
  );
}
