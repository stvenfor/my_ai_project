import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Chat module tokens — resolves from [VercelTokens.current] (light/dark).
abstract final class ChatTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get accent => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get fillSecondary => _t.canvasSoft2;
  static Color get labelPrimary => _t.ink;
  static Color get labelSecondary => _t.body;
  static Color get labelTertiary => _t.mute;
  static Color get separator => _t.hairline;
  /// Self bubble: primary ink, not iMessage blue.
  static Color get selfBubble => _t.primary;
  static Color get peerBubble => _t.canvasSoft2;
  static Color get online => _t.link;
  static Color get unreadBadge => _t.error;

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double bubbleRadius = 8;
  static const double inputRadius = 8;

  static TextStyle get largeTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 36 / 32,
        letterSpacing: -1.6,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get body => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 24 / 16,
      );

  static TextStyle get subhead => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 16 / 12,
      );

  static TextStyle get selfBubbleText => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _t.onPrimary,
        height: 24 / 16,
      );

  static TextStyle get peerBubbleText => TextStyle(
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
