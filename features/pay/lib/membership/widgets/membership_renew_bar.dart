import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipRenewBar extends GetView<MembershipRenewController> {
  const MembershipRenewBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = AppSafeInsets.bottom(context);

    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final price = controller.finalPrice;
      final showCheckbox = controller.showAgreementCheckbox;
      final agreed = controller.agreedToTerms.value;

      return Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
        decoration: const BoxDecoration(
          color: MembershipPalette.cardWhite,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckbox) ...[
              GestureDetector(
                onTap: controller.toggleAgreement,
                child: Row(
                  children: [
                    Image.asset(
                      agreed
                          ? MembershipAssets.iconCheckboxSelected
                          : MembershipAssets.iconCheckboxUnselected,
                      package: MembershipAssets.package,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '已阅读并同意《趣配音会员协议》《趣配音自动续费协议》',
                        style: TextStyle(
                          fontSize: 11,
                          color: MembershipPalette.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: palette.ctaGradient),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.renewNow,
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: Text(
                        '¥${price.toStringAsFixed(2)} 立即续费',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!showCheckbox) ...[
              const SizedBox(height: 8),
              const Text(
                '趣配音会员协议',
                style: TextStyle(
                  fontSize: 11,
                  color: MembershipPalette.textGrayLight,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
