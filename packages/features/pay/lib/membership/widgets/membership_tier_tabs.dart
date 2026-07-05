import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

/// 会员 Tab：左/中/右三切图等宽（各 1/3）+ 图标与文案叠层。
class MembershipTierTabs extends GetView<MembershipRenewController> {
  const MembershipTierTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTier.value;

      return SizedBox(
        height: MembershipDimens.tabBarHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _TabBackgroundRow(
                key: ValueKey<MembershipTier>(selected),
                tier: selected,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TierTapArea(
                    tier: MembershipTier.svip,
                    selected: selected == MembershipTier.svip,
                    iconAsset: MembershipAssets.iconCrownSvip,
                    titleSpans: const [
                      TextSpan(
                        text: 'SVIP',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                    subtitle: '6W内容 无限评分',
                    onTap: () => controller.selectTier(MembershipTier.svip),
                  ),
                ),
                Expanded(
                  child: _TierTapArea(
                    tier: MembershipTier.aiSvip,
                    selected: selected == MembershipTier.aiSvip,
                    iconAsset: MembershipAssets.iconDiamondAi,
                    titleSpans: const [
                      TextSpan(
                        text: 'Ai',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: ' SVIP',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                    subtitle: 'SVIP+AI权益',
                    onTap: () => controller.selectTier(MembershipTier.aiSvip),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _TierTapArea extends StatelessWidget {
  const _TierTapArea({
    required this.tier,
    required this.selected,
    required this.iconAsset,
    required this.titleSpans,
    required this.subtitle,
    required this.onTap,
  });

  final MembershipTier tier;
  final bool selected;
  final String iconAsset;
  final List<InlineSpan> titleSpans;
  final String subtitle;
  final VoidCallback onTap;

  static const _inactiveGreyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 0.65, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: MembershipDimens.tabTitleSize,
                        height: 1.2,
                        color: selected
                            ? MembershipPalette.titleBlack
                            : MembershipPalette.textGray,
                      ),
                      children: titleSpans,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: MembershipDimens.tabSubtitleSize,
                      height: 1.2,
                      color: selected
                          ? MembershipPalette.textGray
                          : MembershipPalette.textGrayLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon = Image.asset(
      iconAsset,
      package: MembershipAssets.package,
      width: MembershipDimens.tabIconWidth,
      height: MembershipDimens.tabIconHeight,
      fit: BoxFit.contain,
    );

    if (selected) {
      return icon;
    }

    if (tier == MembershipTier.svip) {
      return ColorFiltered(colorFilter: _inactiveGreyscale, child: icon);
    }

    return Opacity(opacity: 0.55, child: icon);
  }
}

/// 左 / 中 / 右三切图等宽拼接（各 1/3 屏宽），S 形过渡位于中间段。
class _TabBackgroundRow extends StatelessWidget {
  const _TabBackgroundRow({super.key, required this.tier});

  final MembershipTier tier;

  @override
  Widget build(BuildContext context) {
    final isSvip = tier == MembershipTier.svip;
    final slices = isSvip
        ? [
            MembershipAssets.tabSvipLeft,
            MembershipAssets.tabSvipCenter,
            MembershipAssets.tabSvipRight,
          ]
        : [
            MembershipAssets.tabAiSvipLeft,
            MembershipAssets.tabAiSvipCenter,
            MembershipAssets.tabAiSvipRight,
          ];

    return Row(
      children: [
        for (final asset in slices)
          Expanded(
            child: Image.asset(
              asset,
              package: MembershipAssets.package,
              height: MembershipDimens.tabBarHeight,
              fit: BoxFit.fill,
            ),
          ),
      ],
    );
  }
}
