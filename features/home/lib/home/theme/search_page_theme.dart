import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Search page tokens — resolves from [VercelTokens.current] (light/dark).
abstract final class SearchPageTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get fillSecondary => _t.canvasSoft2;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;

  static Color get rankGold => _t.warning;
  static Color get rankSilver => _t.mute;
  static Color get rankBronze => _t.warningDeep;

  static const double radiusMd = 8;
  static const double contentMaxWidth = 720;
  static const double searchFieldHeight = 44;

  static Color get primaryGreen => accent;
  static Color get titleBlack => labelPrimary;
  static Color get textGray => labelSecondary;
  static Color get subtitleGray => labelTertiary;
  static Color get tagBackground => fillSecondary;
  static Color get tagText => labelPrimary;
  static Color get searchFieldBackground => surface;
  static Color get divider => separator;

  static TextStyle get sectionTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 24 / 16,
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

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator),
      );

  static List<BoxShadow> get cardShadow => const [];
}

abstract final class SearchAssets {
  static const package = 'module_home';
  static const basePath = 'assets/search';

  static String path(String assetName) => '$basePath/$assetName';
}
