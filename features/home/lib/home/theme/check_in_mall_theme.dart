import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

abstract final class CheckInMallTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get primaryBlue => _t.link;
  static Color get background => _t.canvasSoft2;
  static Color get cardWhite => _t.canvas;
  static Color get textPrimary => _t.ink;
  static Color get textSecondary => _t.body;
  static Color get textHint => _t.mute;
  static Color get coinGold => _t.warning;
  static Color get divider => _t.hairline;
}
