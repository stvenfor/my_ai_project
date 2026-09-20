import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Video / dubbing / short-video shared tokens — Vercel Design Source of Truth.
///
/// Prefer [of] in widgets so light/dark follow app [ThemeMode].
/// Statics mirror [VercelTokens.light] for const call sites.
abstract final class VideoTokens {
  static VercelTokens of(BuildContext context) => VercelTokens.of(context);

  // DESIGN.md / VercelTokens.light aliases.
  static const primary = Color(0xFF171717);
  static const onPrimary = Color(0xFFFFFFFF);
  static const link = Color(0xFF0070F3);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF171717);
  static const body = Color(0xFF4D4D4D);
  static const mute = Color(0xFF888888);
  static const hairline = Color(0xFFEBEBEB);
  static const hairlineStrong = Color(0xFFA1A1A1);
  static const error = Color(0xFFEE0000);
  static const warning = Color(0xFFF5A623);
  static const warningSoft = Color(0xFFFFEFCF);
  static const linkSoft = Color(0xFFD3E5FF);
  static const highlightPink = Color(0xFFFF0080);

  /// Overlay chrome on video (always light-on-dark; not theme-inverted).
  static const overlayFg = Color(0xFFFFFFFF);
  static const overlayFgMuted = Color(0xB3FFFFFF);

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: color ?? mute,
      );

  static TextStyle bodyMd({Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: weight,
        height: 24 / 16,
        color: color ?? ink,
      );

  static TextStyle bodySm({Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: weight,
        height: 20 / 14,
        color: color ?? body,
      );
}
