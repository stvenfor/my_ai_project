import 'package:flutter/material.dart';

/// Mobile Type Scale — DESIGN.md roles with phone physical sizes (spec table).
abstract final class VercelTypography {
  static const String fontFamily = 'Geist';
  static const String fontFamilyMono = 'GeistMono';

  static TextTheme textTheme({required Brightness brightness}) {
    final ink = brightness == Brightness.light
        ? const Color(0xFF171717)
        : const Color(0xFFEDEDED);
    final body = brightness == Brightness.light
        ? const Color(0xFF4D4D4D)
        : const Color(0xFFA1A1A1);
    final mute = brightness == Brightness.light
        ? const Color(0xFF888888)
        : const Color(0xFF666666);

    TextStyle base({
      required double size,
      required FontWeight weight,
      required double height,
      double letterSpacing = 0,
      Color? color,
      String family = fontFamily,
    }) {
      return TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color ?? ink,
      );
    }

    // Phone sizes from SPEC Mobile Type Scale table.
    final displayLarge = base(
      size: 32,
      weight: FontWeight.w600,
      height: 36,
      letterSpacing: -1.6,
    );
    final displayMedium = base(
      size: 28,
      weight: FontWeight.w600,
      height: 34,
      letterSpacing: -1.12,
    );
    final displaySmall = base(
      size: 22,
      weight: FontWeight.w600,
      height: 28,
      letterSpacing: -0.88,
    );
    final headlineMedium = base(
      size: 18,
      weight: FontWeight.w600,
      height: 24,
      letterSpacing: -0.54,
    );
    final titleLarge = base(
      size: 17,
      weight: FontWeight.w400,
      height: 26,
      color: body,
    );
    final titleMedium = base(
      size: 16,
      weight: FontWeight.w500,
      height: 24,
    );
    final bodyLarge = base(
      size: 16,
      weight: FontWeight.w400,
      height: 24,
      color: body,
    );
    final bodyMedium = base(
      size: 14,
      weight: FontWeight.w400,
      height: 20,
      letterSpacing: -0.28,
      color: body,
    );
    final bodySmall = base(
      size: 12,
      weight: FontWeight.w400,
      height: 16,
      color: mute,
    );
    final labelLarge = base(
      size: 16,
      weight: FontWeight.w500,
      height: 24,
    );
    final labelMedium = base(
      size: 14,
      weight: FontWeight.w500,
      height: 20,
      letterSpacing: -0.28,
    );
    final labelSmall = base(
      size: 12,
      weight: FontWeight.w400,
      height: 16,
      color: mute,
      family: fontFamilyMono,
    );

    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  /// display-xl role (phone 32) — use for marketing heroes.
  static TextStyle displayXl({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 36 / 32,
        letterSpacing: -1.6,
        color: color,
      );

  static TextStyle captionMono({Color? color}) => TextStyle(
        fontFamily: fontFamilyMono,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: color,
      );

  static TextStyle code({Color? color}) => TextStyle(
        fontFamily: fontFamilyMono,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 20 / 13,
        color: color,
      );
}
