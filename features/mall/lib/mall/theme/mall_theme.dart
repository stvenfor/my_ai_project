import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Mall tokens — resolves from [VercelTokens.current] (light/dark).
abstract final class MallTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;
  static Color get price => _t.error;
  static Color get warning => _t.warning;
  static Color get chipSelectedBg => _t.linkBgSoft;
  static Color get badgeRed => _t.error;
  static Color get badgeGoldBg => _t.warningSoft;
  static Color get badgeGoldText => _t.warningDeep;

  static const double radiusMd = 8;
  static const double radiusLg = 12;

  static TextStyle get searchHint => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get tabActive => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 20 / 15,
        letterSpacing: -0.3,
      );

  static TextStyle get tabInactive => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get cardTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get priceText => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: price,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        height: 16 / 12,
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator),
      );
}
