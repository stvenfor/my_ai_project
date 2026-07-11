import 'package:flutter/material.dart';

/// 认证模块视觉令牌（iOS 极简风格）。
abstract final class AuthTheme {
  // iOS 系统色
  static const accent = Color(0xFF007AFF);
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFE9E9EB);
  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0x993C3C43);
  static const labelTertiary = Color(0x4D3C3C43);
  static const separator = Color(0xFFC6C6C8);
  static const buttonDisabled = Color(0xFFC7C7CC);

  // 兼容旧命名
  static const primaryBlue = accent;
  static const titleBlack = labelPrimary;
  static const textGray = labelSecondary;
  static const linkGray = labelSecondary;
  static const dividerGray = separator;
  static const inputHint = labelTertiary;
  static const countryCodeBg = fillSecondary;

  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double fieldHeight = 52;
  static const double buttonHeight = 52;

  static TextStyle get largeTitle => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get subtitle => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.4,
      );

  static TextStyle get fieldText => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 1.2,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.35,
      );

  static TextStyle get buttonLabel => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get sectionLabel => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.35,
        letterSpacing: -0.08,
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
      );

  static Divider get groupedDivider => const Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 16,
        endIndent: 0,
        color: separator,
      );

  static InputDecoration filledFieldDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: fieldText.copyWith(color: labelTertiary),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: labelSecondary, size: 22),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: separator, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  static InputDecoration groupedFieldDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: fieldText.copyWith(color: labelTertiary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }
}
