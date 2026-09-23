import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

abstract final class AllServicesTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get background => _t.canvas;
  static Color get titleBlack => _t.ink;
  static Color get subtitleGray => _t.mute;
  static Color get labelGray => _t.body;
  static Color get editBorderBlue => _t.link;
}
