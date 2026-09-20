import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Search page tokens — Vercel Design Source of Truth.
abstract final class SearchPageTheme {
  static const accent = Color(0xFF0070F3);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFF5F5F5);
  static const labelPrimary = Color(0xFF171717);
  static const labelSecondary = Color(0xFF4D4D4D);
  static const labelTertiary = Color(0xFF888888);
  static const separator = Color(0xFFEBEBEB);

  static const rankGold = Color(0xFFF5A623);
  static const rankSilver = Color(0xFF888888);
  static const rankBronze = Color(0xFFAB570A);

  static const double radiusMd = 8;
  static const double contentMaxWidth = 720;
  static const double searchFieldHeight = 44;

  static const primaryGreen = accent;
  static const titleBlack = labelPrimary;
  static const textGray = labelSecondary;
  static const subtitleGray = labelTertiary;
  static const tagBackground = fillSecondary;
  static const tagText = labelPrimary;
  static const searchFieldBackground = surface;
  static const divider = separator;

  static TextStyle get sectionTitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get caption => const TextStyle(
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
