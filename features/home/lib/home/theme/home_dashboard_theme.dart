import 'package:flutter/material.dart';

/// 首页仪表盘视觉令牌（iOS 极简风格）。
abstract final class HomeDashboardTheme {
  static const accent = Color(0xFF007AFF);
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFE9E9EB);
  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0x993C3C43);
  static const labelTertiary = Color(0x4D3C3C43);
  static const separator = Color(0xFFC6C6C8);
  static const badgeOrange = Color(0xFFFF9500);
  static const badgeBlue = accent;

  // 兼容旧命名
  static const primaryBlue = accent;
  static const cardWhite = surface;
  static const titleBlack = labelPrimary;
  static const textGray = labelSecondary;
  static const textDarkGray = Color(0xFF3C3C43);
  static const bannerDark = background;

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

  static TextStyle get sectionTitle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 1.2,
      );

  static TextStyle get sectionLabel => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.35,
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF8E8E93).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
