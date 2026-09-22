import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Mall tokens — Vercel Design Source of Truth（对齐 DESIGN.md / MineTheme）。
abstract final class MallTheme {
  static const accent = Color(0xFF0070F3);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const labelPrimary = Color(0xFF171717);
  static const labelSecondary = Color(0xFF4D4D4D);
  static const labelTertiary = Color(0xFF888888);
  static const separator = Color(0xFFEBEBEB);
  static const price = Color(0xFFEE0000);
  static const warning = Color(0xFFF5A623);
  static const chipSelectedBg = Color(0xFFD3E5FF);
  static const badgeRed = Color(0xFFEE0000);
  static const badgeGoldBg = Color(0xFFFFEFCF);
  static const badgeGoldText = Color(0xFFAB570A);

  static const double radiusMd = 8;
  static const double radiusLg = 12;

  static TextStyle get searchHint => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get tabActive => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 20 / 15,
        letterSpacing: -0.3,
      );

  static TextStyle get tabInactive => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get cardTitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get priceText => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: price,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => const TextStyle(
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
