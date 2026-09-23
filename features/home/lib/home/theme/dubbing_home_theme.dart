import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Dubbing home — resolves from [VercelTokens.current]; no green Category Skin.
abstract final class DubbingHomeTheme {
  static VercelTokens get _t => VercelTokens.current();

  static Color get background => _t.canvas;
  static Color get primaryGreen => _t.link;
  static Color get titleBlack => _t.ink;
  static Color get textGray => _t.body;
  static Color get subtitleGray => _t.mute;
  static Color get searchFieldBackground => _t.canvasSoft2;
  static Color get divider => _t.hairline;
  static Color get svipGold => _t.warning;
  static Color get cardShadow => const Color(0x00000000);
  static Color get viewAllBackground => _t.canvasSoft;
  static const sectionTitleSize = 18.0;
  static const cardRadius = 8.0;
  static const thumbRadius = 8.0;

  static Color get hotRankHeaderPink => _t.canvasSoft;
  static Color get hotRankSidebarBg => _t.canvasSoft2;
  static Color get hotRankSidebarActive => _t.canvas;
  static Color get hotRankRankGold => _t.warning;
  static Color get hotRankRankSilver => _t.hairlineStrong;
  static Color get hotRankRankBronze => _t.warningDeep;
  static Color get hotRankRankDefault => _t.mute;
  static const hotRankDropdownShadow = Color(0x1A000000);
}

enum HotRankCardTheme {
  pink(Color(0xFFFDE7E7), Color(0xFFEFC3C4)),
  blue(Color(0xFFE3EDF7), Color(0xFFC3D9EF)),
  green(Color(0xFFE4FDE9), Color(0xFFC3EFD0)),
  tan(Color(0xFFF7EFD4), Color(0xFFEFE0C3)),
  purple(Color(0xFFE4E3FD), Color(0xFFC4C3EF)),
  magenta(Color(0xFFFDE3FA), Color(0xFFEFC3E5));

  const HotRankCardTheme(this.top, this.bottom);

  final Color top;
  final Color bottom;

  LinearGradient get headerGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
        stops: const [0.0, 1.0],
      );

  LinearGradient get bodyGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top.withValues(alpha: 0.5), VercelTokens.current().canvas],
        stops: const [0.0, 0.6],
      );
}

abstract final class DubbingHomeAssets {
  static const package = 'module_home';
  static const basePath = 'assets/dubbing_home';

  static String path(String assetName) => '$basePath/$assetName';

  static String rankBadgeAsset(int rank) {
    switch (rank) {
      case 1:
        return path('rank_badge_1.png');
      case 2:
        return path('rank_badge_2.png');
      case 3:
        return path('rank_badge_3.png');
      default:
        return path('rank_icon_dub.png');
    }
  }
}
