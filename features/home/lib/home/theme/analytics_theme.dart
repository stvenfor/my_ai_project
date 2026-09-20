import 'package:flutter/material.dart';
import 'package:wys_chart/wys_chart.dart';

/// Analytics tokens — Chart Emphasis Zone under Vercel Token API colors.
abstract final class AnalyticsTheme {
  static const Color primary = Color(0xFF171717);
  static const Color secondary = Color(0xFF0070F3);
  static const Color accent = Color(0xFFF5A623);
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF171717);
  static const Color muted = Color(0xFF888888);
  static const Color border = Color(0xFFEBEBEB);
  static const Color destructive = Color(0xFFEE0000);
  static const Color success = Color(0xFF0070F3);

  static const double cardRadius = 8;
  static const double gridGap = 8;

  static const WysChartColors chartColors = WysChartColors.vercel;
}
