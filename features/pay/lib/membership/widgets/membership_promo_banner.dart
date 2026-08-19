import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipPromoBanner extends GetView<MembershipRenewController> {
  const MembershipPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final promo = controller.currentPromo;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.promoBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.promoAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promo.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MembershipPalette.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '距结束还剩',
                    style: TextStyle(
                      fontSize: 11,
                      color: MembershipPalette.textGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    promo.countdownLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.promoAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
