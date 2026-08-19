import 'package:flutter/material.dart';

/// 我的页视觉令牌（iOS 极简风格）。
abstract final class MineTheme {
  static const accent = Color(0xFF007AFF);
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFE9E9EB);
  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0x993C3C43);
  static const labelTertiary = Color(0x4D3C3C43);
  static const separator = Color(0xFFC6C6C8);

  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double contentMaxWidth = 720;

  static TextStyle get largeTitle => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get headline => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 1.2,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 1.35,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.35,
      );

  static TextStyle get statValue => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        height: 1.1,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator, width: 0.5),
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF8E8E93).withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
