import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipPlanCarousel extends GetView<MembershipRenewController> {
  const MembershipPlanCarousel({super.key});

  /// 左右边距与卡片间距相等，三卡等宽铺满可用宽度。
  static ({double inset, double cardWidth}) layoutMetrics(double maxWidth) {
    const designCardWidth = MembershipDimens.planCardWidth;
    final spare = maxWidth - designCardWidth * 3;
    if (spare >= 0) {
      final inset = spare / 4;
      return (inset: inset, cardWidth: designCardWidth);
    }

    const minInset = 8.0;
    final cardWidth = (maxWidth - minInset * 4) / 3;
    return (inset: minInset, cardWidth: cardWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final plans = controller.currentPlans.toList();
      final selectedPlanId = controller.selectedPlanId.value;
      final countdown = controller.redPacketCountdown.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final metrics = layoutMetrics(constraints.maxWidth);
          final inset = metrics.inset;
          final cardWidth = metrics.cardWidth;

          return SizedBox(
            height: MembershipDimens.planCarouselHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: inset),
                for (var index = 0; index < plans.length; index++) ...[
                  if (index > 0) SizedBox(width: inset),
                  SizedBox(
                    width: cardWidth,
                    child: _PlanCard(
                      plan: plans[index],
                      selected: plans[index].id == selectedPlanId,
                      palette: palette,
                      countdown: countdown,
                      cardWidth: cardWidth,
                      onTap: () => controller.selectPlan(plans[index].id),
                    ),
                  ),
                ],
                SizedBox(width: inset),
              ],
            ),
          );
        },
      );
    });
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.palette,
    required this.countdown,
    required this.cardWidth,
    required this.onTap,
  });

  final MembershipPlan plan;
  final bool selected;
  final MembershipPalette palette;
  final String countdown;
  final double cardWidth;
  final VoidCallback onTap;

  static const _trialBadgeLabel = '开学尝鲜价';

  bool get _isTrialBadge => plan.badge == _trialBadgeLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: cardWidth,
            height: MembershipDimens.planCardHeight,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFF8ED)
                  : MembershipPalette.cardWhite,
              borderRadius:
                  BorderRadius.circular(MembershipDimens.planCardRadius),
              border: Border.all(
                color: selected
                    ? palette.planBorder
                    : MembershipPalette.planBorderUnselected,
                width: selected ? 1.5 : 1,
              ),
              image: selected
                  ? DecorationImage(
                      image: AssetImage(
                        MembershipAssets.memberCardBg,
                        package: MembershipAssets.package,
                      ),
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: plan.badge != null ? 22 : 12),
                    Expanded(
                      child: _PlanCardContent(plan: plan),
                    ),
                    if (selected && plan.showRedPacket)
                      _RedPacketFooter(
                        palette: palette,
                        countdown: countdown,
                      )
                    else if (!selected && plan.dailyHint != null)
                      _DailyHintFooter(
                        hint: plan.dailyHint!,
                        palette: palette,
                      )
                    else
                      SizedBox(height: selected ? 8 : 10),
                  ],
                ),
                if (plan.badge != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _PlanBadge(
                      label: plan.badge!,
                      selected: selected,
                      isTrial: _isTrialBadge,
                      palette: palette,
                    ),
                  ),
              ],
            ),
          ),
          if (selected)
            CustomPaint(
              size: const Size(
                12,
                MembershipDimens.planCardPointerHeight,
              ),
              painter: _PlanPointerPainter(color: palette.accent),
            )
          else
            const SizedBox(height: MembershipDimens.planCardPointerHeight),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({
    required this.label,
    required this.selected,
    required this.isTrial,
    required this.palette,
  });

  final String label;
  final bool selected;
  final bool isTrial;
  final MembershipPalette palette;

  @override
  Widget build(BuildContext context) {
    if (isTrial && selected) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 8, 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.accent, palette.accentLight],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(MembershipDimens.planCardRadius),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: MembershipPalette.planBadgePromoBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.accent,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}

class _PlanCardContent extends StatelessWidget {
  const _PlanCardContent({required this.plan});

  final MembershipPlan plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            plan.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: MembershipPalette.titleBlack,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          _PlanPriceRow(price: plan.price),
          const SizedBox(height: 2),
          Text(
            '¥${plan.originalPrice.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: MembershipPalette.originalPriceGray,
              decoration: TextDecoration.lineThrough,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanPriceRow extends StatelessWidget {
  const _PlanPriceRow({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          '¥',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MembershipPalette.priceBlack,
            height: 1,
          ),
        ),
        Text(
          price.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: MembershipPalette.priceBlack,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _RedPacketFooter extends StatelessWidget {
  const _RedPacketFooter({
    required this.palette,
    required this.countdown,
  });

  final MembershipPalette palette;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      color: palette.accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            palette.redPacketIcon,
            package: MembershipAssets.package,
            width: 12,
            height: 12,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              '8元红包 $countdown',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyHintFooter extends StatelessWidget {
  const _DailyHintFooter({
    required this.hint,
    required this.palette,
  });

  final String hint;
  final MembershipPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: MembershipPalette.planFooterPeach,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(MembershipDimens.planCardRadius - 1),
        ),
      ),
      child: Text(
        hint,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: palette.accent,
          height: 1.2,
        ),
      ),
    );
  }
}

class _PlanPointerPainter extends CustomPainter {
  const _PlanPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PlanPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
