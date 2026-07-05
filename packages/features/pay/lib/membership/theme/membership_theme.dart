import 'package:flutter/material.dart';
import 'package:module_pay/membership/model/membership_models.dart';

/// 会员页尺寸 token（设计稿 375×812 @1x pt）。
abstract final class MembershipDimens {
  /// Tab 背景切图 188×84px，显示高度为切图逻辑高度的一半（42pt）。
  static const double tabBarDesignWidth = 188;
  static const double tabBarDesignSliceHeight = 84;
  static const double tabBarHeight = 42;

  /// 图标与字号随 Tab 高度同比缩放。
  static const double tabIconWidth = 18;
  static const double tabIconHeight = 14;
  static const double tabTitleSize = 13;
  static const double tabSubtitleSize = 8;

  /// 套餐横滑卡片（设计稿 118×148 @1x pt）。
  static const double planCardWidth = 118;
  static const double planCardHeight = 148;
  static const double planCardRadius = 12;
  static const double planCardGap = 10;
  static const double planCardPointerHeight = 6;
  static const double planCarouselHeight =
      planCardHeight + planCardPointerHeight;
}

class MembershipPalette {
  const MembershipPalette({
    required this.headerGradient,
    required this.accent,
    required this.accentLight,
    required this.planBorder,
    required this.ctaGradient,
    required this.promoBackground,
    required this.promoAccent,
    required this.deductionHighlight,
    required this.tabSelectedAssetLeft,
    required this.tabSelectedAssetRight,
    required this.tabUnselectedAssetLeft,
    required this.tabUnselectedAssetRight,
    required this.illustrationAsset,
    required this.redPacketIcon,
    required this.radioSelected,
    required this.radioUnselected,
  });

  final List<Color> headerGradient;
  final Color accent;
  final Color accentLight;
  final Color planBorder;
  final List<Color> ctaGradient;
  final Color promoBackground;
  final Color promoAccent;
  final Color deductionHighlight;
  final String tabSelectedAssetLeft;
  final String tabSelectedAssetRight;
  final String tabUnselectedAssetLeft;
  final String tabUnselectedAssetRight;
  final String illustrationAsset;
  final String redPacketIcon;
  final String radioSelected;
  final String radioUnselected;

  static const Color titleBlack = Color(0xFF333333);
  static const Color textGray = Color(0xFF999999);
  static const Color textGrayLight = Color(0xFFBFBFBF);
  static const Color pageBackground = Color(0xFFF7F7F7);
  static const Color cardWhite = Colors.white;
  static const Color priceBlack = Color(0xFF1A1A1A);
  static const Color originalPriceGray = Color(0xFFBFBFBF);
  static const Color deductionOrange = Color(0xFFFF8A34);
  static const Color beanOrange = Color(0xFFFF8A34);
  static const Color planBadgePromoBg = Color(0xFFFFF8E6);
  static const Color planFooterPeach = Color(0xFFFFF3E8);
  static const Color planBorderUnselected = Color(0xFFEEEEEE);

  static MembershipPalette of(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.svip => const MembershipPalette(
          headerGradient: [Color(0xFFFFF3D4), Color(0xFFFFFFFF)],
          accent: Color(0xFFFF8A34),
          accentLight: Color(0xFFFFB800),
          planBorder: Color(0xFFFF8A34),
          ctaGradient: [Color(0xFFFFD36A), Color(0xFFFF8A34)],
          promoBackground: Color(0xFFEFF8E8),
          promoAccent: Color(0xFF52C41A),
          deductionHighlight: Color(0xFFFF8A34),
          tabSelectedAssetLeft: 'assets/membership/tab_svip_left.png',
          tabSelectedAssetRight: 'assets/membership/tab_svip_right.png',
          tabUnselectedAssetLeft: 'assets/membership/tab_ai_svip_left.png',
          tabUnselectedAssetRight: 'assets/membership/tab_ai_svip_right.png',
          illustrationAsset: 'assets/membership/illustration_svip.png',
          redPacketIcon: 'assets/membership/icon_red_packet_svip.png',
          radioSelected: 'assets/membership/icon_radio_selected_svip.png',
          radioUnselected: 'assets/membership/icon_radio_unselected_svip.png',
        ),
      MembershipTier.aiSvip => const MembershipPalette(
          headerGradient: [Color(0xFFE8E1FF), Color(0xFFFFFFFF)],
          accent: Color(0xFF9D7CFF),
          accentLight: Color(0xFF7B5CFF),
          planBorder: Color(0xFF9D7CFF),
          ctaGradient: [Color(0xFF9D7CFF), Color(0xFF5B7CFF)],
          promoBackground: Color(0xFFF3EEFF),
          promoAccent: Color(0xFF9D7CFF),
          deductionHighlight: Color(0xFFFF8A34),
          tabSelectedAssetLeft: 'assets/membership/tab_ai_svip_left.png',
          tabSelectedAssetRight: 'assets/membership/tab_ai_svip_right.png',
          tabUnselectedAssetLeft: 'assets/membership/tab_svip_left.png',
          tabUnselectedAssetRight: 'assets/membership/tab_svip_right.png',
          illustrationAsset: 'assets/membership/illustration_ai_svip.png',
          redPacketIcon: 'assets/membership/icon_red_packet_ai.png',
          radioSelected: 'assets/membership/icon_radio_selected_ai.png',
          radioUnselected: 'assets/membership/icon_radio_unselected_ai.png',
        ),
    };
  }
}
