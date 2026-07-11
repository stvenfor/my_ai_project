import 'package:flutter/material.dart';

/// 聊天模块视觉令牌（iOS 极简 / iMessage 风格）。
abstract final class ChatTheme {
  static const accent = Color(0xFF007AFF);
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const fillSecondary = Color(0xFFE9E9EB);
  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0x993C3C43);
  static const labelTertiary = Color(0x4D3C3C43);
  static const separator = Color(0xFFC6C6C8);
  static const selfBubble = accent;
  static const peerBubble = fillSecondary;
  static const online = Color(0xFF34C759);
  static const unreadBadge = Color(0xFFFF3B30);

  static const double radiusMd = 12;
  static const double radiusLg = 18;
  static const double bubbleRadius = 18;
  static const double inputRadius = 20;

  static TextStyle get largeTitle => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get headline => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        height: 1.2,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 1.35,
      );

  static TextStyle get subhead => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.3,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        height: 1.3,
      );

  static TextStyle get selfBubbleText => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.35,
      );

  static TextStyle get peerBubbleText => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        height: 1.35,
      );

  static BoxDecoration get groupedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
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
