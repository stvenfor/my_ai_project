import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/mock/membership_mock_data.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipDeductionRow extends GetView<MembershipRenewController> {
  const MembershipDeductionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final selected = controller.useDeduction.value;
      final amount = MembershipMockData.deductionAmount.toStringAsFixed(0);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Material(
          color: MembershipPalette.cardWhite,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: controller.toggleDeduction,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Image.asset(
                    palette.illustrationAsset,
                    package: MembershipAssets.package,
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: MembershipPalette.titleBlack,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: '剩余会员天数可抵扣 '),
                              TextSpan(
                                text: '$amount 元',
                                style: TextStyle(
                                  color: palette.deductionHighlight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SVIP抵扣0.7元/天，VIP抵扣0.3元/天',
                          style: TextStyle(
                            fontSize: 11,
                            color: MembershipPalette.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    selected ? palette.radioSelected : palette.radioUnselected,
                    package: MembershipAssets.package,
                    width: 22,
                    height: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
