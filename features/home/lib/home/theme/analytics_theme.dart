import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:wys_chart/wys_chart.dart';

/// Analytics tokens — Chart Emphasis Zone under Vercel Token API colors.
abstract final class AnalyticsTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get primary => _t.primary;
  static Color get secondary => _t.link;
  static Color get accent => _t.warning;
  static Color get background => _t.canvasSoft2;
  static Color get card => _t.canvas;
  static Color get foreground => _t.ink;
  static Color get muted => _t.mute;
  static Color get border => _t.hairline;
  static Color get destructive => _t.error;
  static Color get success => _t.success;

  static const double cardRadius = 8;
  static const double gridGap = 8;

  static const WysChartColors chartColors = WysChartColors.vercel;
}
