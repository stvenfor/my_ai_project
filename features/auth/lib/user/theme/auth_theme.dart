import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Auth module tokens — Vercel Design Source of Truth.
abstract final class AuthTheme {
  static const accent = Color(0xFF0070F3);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFF5F5F5);
  static const labelPrimary = Color(0xFF171717);
  static const labelSecondary = Color(0xFF4D4D4D);
  static const labelTertiary = Color(0xFF888888);
  static const separator = Color(0xFFEBEBEB);
  static const buttonDisabled = Color(0xFFA1A1A1);

  static const primaryBlue = accent;
  static const titleBlack = labelPrimary;
  static const textGray = labelSecondary;
  static const linkGray = labelSecondary;
  static const dividerGray = separator;
  static const inputHint = labelTertiary;
  static const countryCodeBg = fillSecondary;

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double fieldHeight = 52;
  static const double buttonHeight = 52;

  static TextStyle get largeTitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 36 / 32,
        letterSpacing: -1.6,
      );

  static TextStyle get subtitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get fieldText => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 16 / 12,
      );

  static TextStyle get buttonLabel => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFFFFFF),
        height: 24 / 16,
      );

  static TextStyle get sectionLabel => const TextStyle(
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
        borderSide: const BorderSide(color: separator),
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
