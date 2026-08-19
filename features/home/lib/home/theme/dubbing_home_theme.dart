import 'package:flutter/material.dart';

abstract final class DubbingHomeTheme {
  static const background = Colors.white;
  static const primaryGreen = Color(0xFF45D1A1);
  static const titleBlack = Color(0xFF1A1A1A);
  static const textGray = Color(0xFF666666);
  static const subtitleGray = Color(0xFF999999);
  static const searchFieldBackground = Color(0xFFF5F5F5);
  static const divider = Color(0xFFEEEEEE);
  static const svipGold = Color(0xFFD4A017);
  static const cardShadow = Color(0x14000000);
  static const viewAllBackground = Color(0xFFFAFAFA);
  static const sectionTitleSize = 18.0;
  static const cardRadius = 12.0;
  static const thumbRadius = 8.0;

  // 热搜榜详情页
  static const hotRankHeaderPink = Color(0xFFFFF0F5);
  static const hotRankSidebarBg = Color(0xFFF7F8FA);
  static const hotRankSidebarActive = Colors.white;
  static const hotRankRankGold = Color(0xFFFFC107);
  static const hotRankRankSilver = Color(0xFFCFD8DC);
  static const hotRankRankBronze = Color(0xFFFFCCBC);
  static const hotRankRankDefault = Color(0xFFBDBDBD);
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
        colors: [top.withValues(alpha: 0.5), Colors.white],
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
