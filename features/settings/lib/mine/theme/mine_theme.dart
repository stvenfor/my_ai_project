import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Mine page tokens — resolves from [VercelTokens.current] (light/dark).
abstract final class MineTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get fillSecondary => _t.canvasSoft2;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double contentMaxWidth = 720;

  static TextStyle get largeTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 36 / 32,
        letterSpacing: -1.6,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 24 / 18,
        letterSpacing: -0.54,
      );

  static TextStyle get body => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get statValue => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 28 / 22,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator),
      );

  static List<BoxShadow> get cardShadow => const [];
}
