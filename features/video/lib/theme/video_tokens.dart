import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Video / dubbing / short-video shared tokens — Vercel Design Source of Truth.
///
/// Prefer [of] in widgets so light/dark follow app [ThemeMode].
/// Legacy static getters also follow [VercelTokens.current].
abstract final class VideoTokens {
  static VercelTokens of(BuildContext context) => VercelTokens.of(context);

  static VercelTokens get _t => VercelTokens.current();

  static Color get primary => _t.primary;
  static Color get onPrimary => _t.onPrimary;
  static Color get link => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get surface => _t.canvas;
  static Color get ink => _t.ink;
  static Color get body => _t.body;
  static Color get mute => _t.mute;
  static Color get hairline => _t.hairline;
  static Color get hairlineStrong => _t.hairlineStrong;
  static Color get error => _t.error;
  static Color get warning => _t.warning;
  static Color get warningSoft => _t.warningSoft;
  static Color get linkSoft => _t.linkBgSoft;
  static Color get highlightPink => _t.highlightPink;

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
