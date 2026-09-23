import 'package:flutter/material.dart';

/// 售后专区视觉 token（与 Mine「售后」橙点呼应，对齐二手车页结构）。
abstract final class AfterSalesTheme {
  static const background = Color(0xFFF3F5F8);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1C2430);
  static const mute = Color(0xFF6B7280);
  static const hairline = Color(0xFFE5E7EB);
  static const accent = Color(0xFFD97706);
  static const accentDeep = Color(0xFFB45309);
  static const repair = Color(0xFFDC2626);
  static const maintenance = Color(0xFF059669);

  static const radiusCard = 14.0;
  static const radiusChip = 8.0;

  static TextStyle get title => const TextStyle(
        color: ink,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get body => const TextStyle(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get caption => const TextStyle(
        color: mute,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );

  static TextStyle get sectionTitle => const TextStyle(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static BoxDecoration get card => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: hairline),
      );

  static InputDecoration fieldDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: surface,
        labelStyle: caption,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  static Color kindColor(int kind) =>
      kind == 0 ? repair : maintenance;
}
