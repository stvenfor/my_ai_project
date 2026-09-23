import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Home dashboard visual tokens — resolves from [VercelTokens.current].
abstract final class HomeDashboardTheme {
  static VercelTokens tokens(BuildContext context) => VercelTokens.of(context);

  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get fillSecondary => _t.canvasSoft2;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;
  static Color get badgeOrange => _t.warning;
  static Color get badgeBlue => accent;

  static Color get primaryBlue => accent;
  static Color get cardWhite => surface;
  static Color get titleBlack => labelPrimary;
  static Color get textGray => labelSecondary;
  static Color get textDarkGray => labelSecondary;
  static Color get bannerDark => background;

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

  static TextStyle get sectionTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 24 / 18,
        letterSpacing: -0.54,
      );

  static TextStyle get sectionLabel => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator),
      );

  /// Vercel surfaces are flat — no soft iOS card shadow.
  static List<BoxShadow> get cardShadow => const [];
}
