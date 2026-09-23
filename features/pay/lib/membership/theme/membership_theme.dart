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

/// Pay / membership visual tokens — resolves from [VercelTokens.current].
abstract final class MembershipTheme {
  static VercelTokens tokens(BuildContext context) => VercelTokens.of(context);

  static VercelTokens get _t => VercelTokens.current();

  static Color get ink => _t.ink;
  static Color get body => _t.body;
  static Color get mute => _t.mute;
  static Color get hairline => _t.hairline;
  static Color get hairlineStrong => _t.hairlineStrong;
  static Color get canvas => _t.canvas;
  static Color get canvasSoft => _t.canvasSoft;
  static Color get canvasSoft2 => _t.canvasSoft2;
  static Color get link => _t.link;
  static Color get linkBgSoft => _t.linkBgSoft;
  static Color get warning => _t.warning;
  static Color get warningSoft => _t.warningSoft;
  static Color get warningDeep => _t.warningDeep;
  static Color get onPrimary => _t.onPrimary;

  // Legacy aliases used across membership widgets.
  static Color get titleBlack => ink;
  static Color get textGray => mute;
  static Color get textGrayLight => hairlineStrong;
  static Color get pageBackground => canvasSoft2;
  static Color get cardWhite => canvas;
  static Color get priceBlack => ink;
  static Color get originalPriceGray => hairlineStrong;
  static Color get deductionOrange => warning;
  static Color get beanOrange => warning;
  static Color get planBadgePromoBg => warningSoft;
  static Color get planFooterPeach => warningSoft;
  static Color get planBorderUnselected => hairline;

  static const double radiusMd = MembershipDimens.cardRadius;

  static TextStyle get displaySm => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 24 / 18,
        letterSpacing: -0.54,
      );

  static TextStyle get sectionTitle => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 28 / 22,
        letterSpacing: -0.88,
      );

  static TextStyle get bodyMd => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: body,
        height: 24 / 16,
      );

  static TextStyle get bodySm => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: body,
        height: 20 / 14,
        letterSpacing: -0.28,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mute,
        height: 16 / 12,
      );

  static TextStyle get captionStrong => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 16 / 12,
      );

  static TextStyle get buttonLg => TextStyle(
        fontFamily: VercelTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onPrimary,
        height: 24 / 16,
      );

  static TextStyle get priceDisplay => TextStyle(
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

  static Color get titleBlack => MembershipTheme.titleBlack;
  static Color get textGray => MembershipTheme.textGray;
  static Color get textGrayLight => MembershipTheme.textGrayLight;
  static Color get pageBackground => MembershipTheme.pageBackground;
  static Color get cardWhite => MembershipTheme.cardWhite;
  static Color get priceBlack => MembershipTheme.priceBlack;
  static Color get originalPriceGray => MembershipTheme.originalPriceGray;
  static Color get deductionOrange => MembershipTheme.deductionOrange;
  static Color get beanOrange => MembershipTheme.beanOrange;
  static Color get planBadgePromoBg => MembershipTheme.planBadgePromoBg;
  static Color get planFooterPeach => MembershipTheme.planFooterPeach;
  static Color get planBorderUnselected => MembershipTheme.planBorderUnselected;

  static MembershipPalette of(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.svip => MembershipPalette(
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
      MembershipTier.aiSvip => MembershipPalette(
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
