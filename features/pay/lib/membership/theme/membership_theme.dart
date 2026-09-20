import 'package:flutter/material.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_pay/membership/model/membership_models.dart';

/// Membership layout tokens (design 375×812 @1x pt). Visual colors live on
/// [MembershipTheme] / [VercelTokens] — not a feature-owned palette.
abstract final class MembershipDimens {
  /// Tab 背景切图 188×84px（左/中/右各 1/3，总宽 564px @3x）。
  static const double tabBarDesignSliceWidth = 188;
  static const double tabBarDesignSliceHeight = 84;
  static const double tabBarDesignTotalWidth = tabBarDesignSliceWidth * 3;
  /// 历史固定高度；请优先使用 [tabBarHeightForWidth]。
  static const double tabBarHeight = 42;

  static double tabBarHeightForWidth(double width) =>
      width * tabBarDesignSliceHeight / tabBarDesignTotalWidth;

  static double headerTotalHeight(BuildContext context, double width) =>
      headerExpandedHeight(context) + tabBarHeightForWidth(width);

  /// 图标与字号随 Tab 高度同比缩放。
  static const double tabIconWidth = 18;
  static const double tabIconHeight = 14;
  static const double tabTitleSize = 13;
  static const double tabSubtitleSize = 8;

  /// Header 内容区（不含状态栏）：顶距 + 操作行 + 间距 + 头像行 + 底距。
  static const double headerTopPadding = 8;
  static const double headerActionRowHeight = 38;
  static const double headerProfileGap = 12;
  static const double headerAvatarSize = 48;
  static const double headerBottomPadding = 10;
  static const double headerBodyHeight = headerTopPadding +
      headerActionRowHeight +
      headerProfileGap +
      headerAvatarSize +
      headerBottomPadding;

  /// Header 背景切图 563×344 @3x。
  static const double headerBgAspectRatio = 563 / 344;

  /// 折叠导航条高度（状态栏 + 工具栏）。
  static double collapsedNavHeight(BuildContext context) =>
      AppSafeInsets.navBarHeight(context);

  /// Header 展开总高度。
  static double headerExpandedHeight(BuildContext context) =>
      AppSafeInsets.top(context) + headerBodyHeight;

  /// 用户信息区滚出顶部时的 scroll 阈值。
  static double navCollapseThreshold(BuildContext context) =>
      AppSafeInsets.top(context) +
      headerTopPadding +
      headerActionRowHeight +
      headerProfileGap +
      headerAvatarSize;

  /// 套餐横滑卡片（设计稿 118×148 @1x pt）。
  static const double planCardWidth = 118;
  static const double planCardHeight = 148;
  static const double planCardRadius = 8;
  static const double planCardGap = 10;
  static const double planCardPointerHeight = 6;
  static const double planCarouselHeight =
      planCardHeight + planCardPointerHeight;

  static const double cardRadius = 8;
  static const double ctaRadius = 100;
}

/// Pay / membership visual tokens — Vercel Design Source of Truth.
/// Prefer [VercelTokens.of] in widgets; statics mirror light for const call sites.
abstract final class MembershipTheme {
  static VercelTokens tokens(BuildContext context) => VercelTokens.of(context);

  static const Color ink = Color(0xFF171717);
  static const Color body = Color(0xFF4D4D4D);
  static const Color mute = Color(0xFF888888);
  static const Color hairline = Color(0xFFEBEBEB);
  static const Color hairlineStrong = Color(0xFFA1A1A1);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFFAFAFA);
  static const Color canvasSoft2 = Color(0xFFF5F5F5);
  static const Color link = Color(0xFF0070F3);
  static const Color linkBgSoft = Color(0xFFD3E5FF);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSoft = Color(0xFFFFEFCF);
  static const Color warningDeep = Color(0xFFAB570A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Legacy aliases used across membership widgets.
  static const Color titleBlack = ink;
  static const Color textGray = mute;
  static const Color textGrayLight = hairlineStrong;
  static const Color pageBackground = canvasSoft2;
  static const Color cardWhite = canvas;
  static const Color priceBlack = ink;
  static const Color originalPriceGray = hairlineStrong;
  static const Color deductionOrange = warning;
  static const Color beanOrange = warning;
  static const Color planBadgePromoBg = warningSoft;
  static const Color planFooterPeach = warningSoft;
  static const Color planBorderUnselected = hairline;

  static const double radiusMd = MembershipDimens.cardRadius;

  static TextStyle get displaySm => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 24 / 18,
        letterSpacing: -0.54,
      );

  static TextStyle get sectionTitle => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 28 / 22,
        letterSpacing: -0.88,
      );

  static TextStyle get bodyMd => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: body,
        height: 24 / 16,
      );

  static TextStyle get bodySm => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: body,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mute,
        height: 16 / 12,
      );

  static TextStyle get captionStrong => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 16 / 12,
      );

  static TextStyle get buttonLg => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onPrimary,
        height: 24 / 16,
      );

  static TextStyle get priceDisplay => const TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1,
        letterSpacing: -1.0,
      );

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? canvas,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: hairline),
      );

  /// Flat Vercel surfaces — no iOS drop shadow.
  static List<BoxShadow> get cardShadow => const [];
}

/// Tier-specific **assets** plus shared Vercel semantic colors.
/// Accents no longer own orange/purple Category Skins.
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

  static const Color titleBlack = MembershipTheme.titleBlack;
  static const Color textGray = MembershipTheme.textGray;
  static const Color textGrayLight = MembershipTheme.textGrayLight;
  static const Color pageBackground = MembershipTheme.pageBackground;
  static const Color cardWhite = MembershipTheme.cardWhite;
  static const Color priceBlack = MembershipTheme.priceBlack;
  static const Color originalPriceGray = MembershipTheme.originalPriceGray;
  static const Color deductionOrange = MembershipTheme.deductionOrange;
  static const Color beanOrange = MembershipTheme.beanOrange;
  static const Color planBadgePromoBg = MembershipTheme.planBadgePromoBg;
  static const Color planFooterPeach = MembershipTheme.planFooterPeach;
  static const Color planBorderUnselected = MembershipTheme.planBorderUnselected;

  static MembershipPalette of(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.svip => const MembershipPalette(
          headerGradient: [
            MembershipTheme.canvasSoft,
            MembershipTheme.canvas,
          ],
          accent: MembershipTheme.ink,
          accentLight: MembershipTheme.body,
          planBorder: MembershipTheme.ink,
          ctaGradient: [MembershipTheme.ink, MembershipTheme.ink],
          promoBackground: MembershipTheme.warningSoft,
          promoAccent: MembershipTheme.warningDeep,
          deductionHighlight: MembershipTheme.warning,
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
          headerGradient: [
            MembershipTheme.canvasSoft,
            MembershipTheme.canvas,
          ],
          accent: MembershipTheme.ink,
          accentLight: MembershipTheme.body,
          planBorder: MembershipTheme.ink,
          ctaGradient: [MembershipTheme.ink, MembershipTheme.ink],
          promoBackground: MembershipTheme.linkBgSoft,
          promoAccent: MembershipTheme.link,
          deductionHighlight: MembershipTheme.warning,
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
