import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Auth module tokens — resolves from [VercelTokens.current] (light/dark).
abstract final class AuthTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get fillSecondary => _t.canvasSoft2;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;
  static Color get buttonDisabled => _t.hairlineStrong;

  static Color get primaryBlue => accent;
  static Color get titleBlack => labelPrimary;
  static Color get textGray => labelSecondary;
  static Color get linkGray => labelSecondary;
  static Color get dividerGray => separator;
  static Color get inputHint => labelTertiary;
  static Color get countryCodeBg => fillSecondary;

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double fieldHeight = 52;
  static const double buttonHeight = 52;

  static TextStyle get largeTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 36 / 32,
        letterSpacing: -1.6,
      );

  static TextStyle get subtitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get fieldText => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 16 / 12,
      );

  static TextStyle get buttonLabel => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _t.onPrimary,
        height: 24 / 16,
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

  static Divider get groupedDivider => Divider(
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
        borderSide: BorderSide(color: separator),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: accent, width: 1.5),
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
