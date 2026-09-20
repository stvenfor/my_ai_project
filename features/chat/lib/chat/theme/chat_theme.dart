import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Chat module tokens — Vercel surfaces (no iMessage Category Skin).
abstract final class ChatTheme {
  static const accent = Color(0xFF0070F3);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFF5F5F5);
  static const labelPrimary = Color(0xFF171717);
  static const labelSecondary = Color(0xFF4D4D4D);
  static const labelTertiary = Color(0xFF888888);
  static const separator = Color(0xFFEBEBEB);
  /// Self bubble: primary ink (Vercel primary), not iMessage blue.
  static const selfBubble = Color(0xFF171717);
  static const peerBubble = Color(0xFFF5F5F5);
  static const online = Color(0xFF0070F3);
  static const unreadBadge = Color(0xFFEE0000);

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double bubbleRadius = 8;
  static const double inputRadius = 8;

  static TextStyle get largeTitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 36 / 32,
        letterSpacing: -1.6,
      );

  static TextStyle get headline => const TextStyle(
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

  static TextStyle get subhead => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 16 / 12,
      );

  static TextStyle get selfBubbleText => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFFFFFF),
        height: 24 / 16,
      );

  static TextStyle get peerBubbleText => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: separator),
      );

  static Divider groupedDivider({double indent = 72}) => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: indent,
        color: separator,
      );

  static BorderRadius bubbleRadiusFor({required bool isSelf}) {
    return BorderRadius.only(
      topLeft: const Radius.circular(bubbleRadius),
      topRight: const Radius.circular(bubbleRadius),
      bottomLeft: Radius.circular(isSelf ? bubbleRadius : 4),
      bottomRight: Radius.circular(isSelf ? 4 : bubbleRadius),
    );
  }
}
