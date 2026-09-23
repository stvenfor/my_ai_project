import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Classroom — resolves from [VercelTokens.current]; no green Category Skin.
abstract final class ClassroomColors {
  static VercelTokens get _t => VercelTokens.current();

  static Color get background => _t.canvasSoft2;
  static Color get cardWhite => _t.canvas;
  static Color get primaryGreen => _t.primary;
  static Color get primaryGreenDark => _t.primary;
  static Color get primaryGreenLight => _t.canvasSoft2;
  static Color get gradientEnd => _t.link;
  static Color get titleBlack => _t.ink;
  static Color get textGray => _t.mute;
  static Color get textGrayLight => _t.hairlineStrong;
  static Color get divider => _t.hairline;
  static Color get orange => _t.warning;
  static Color get cardBlue => _t.link;
  static Color get stampGray => _t.hairline;
  static Color get noteBackground => _t.linkBgSoft;
  static Color get giftCardBlue => _t.link;
}

abstract final class ClassroomDimens {
  static const double cardRadius = 8;
  static const double buttonRadius = 100; // DESIGN.md pill
  static const double pagePadding = 16;
}
