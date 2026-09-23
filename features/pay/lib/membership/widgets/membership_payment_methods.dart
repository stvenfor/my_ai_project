import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipPaymentMethods extends GetView<MembershipRenewController> {
  const MembershipPaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.paymentMethod.value;
      final methods = controller.availablePaymentMethods;
      final balance = controller.walletBalance.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: MembershipPalette.cardWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < methods.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, indent: 56, color: Color(0xFFEBEBEB)),
                _tileFor(methods[i], selected, balance),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _tileFor(
    PaymentMethodType method,
    PaymentMethodType selected,
    String balance,
  ) {
    switch (method) {
      case PaymentMethodType.wechat:
        return _PaymentTile(
          iconAsset: MembershipAssets.iconWechat,
          title: '微信支付',
          subtitle: '（时长买断）',
          selected: selected == method,
          onTap: () => controller.selectPayment(method),
        );
      case PaymentMethodType.alipay:
        return _PaymentTile(
          iconAsset: MembershipAssets.iconAlipay,
          title: '支付宝支付',
          subtitle: '（时长买断）',
          selected: selected == method,
          onTap: () => controller.selectPayment(method),
        );
      case PaymentMethodType.balance:
        return _PaymentTile(
          iconAsset: MembershipAssets.iconAlipay,
          title: '余额支付',
          subtitle: '（可用 ¥$balance）',
          selected: selected == method,
          onTap: () => controller.selectPayment(method),
        );
      case PaymentMethodType.huawei:
        return _PaymentTile(
          iconAsset: MembershipAssets.iconWechat,
          title: '华为内购',
          subtitle: '（自动续费订阅）',
          selected: selected == method,
          onTap: () => controller.selectPayment(method),
        );
      case PaymentMethodType.apple:
        return _PaymentTile(
          iconAsset: MembershipAssets.iconAlipay,
          title: '苹果内购',
          subtitle: '（自动续费订阅）',
          selected: selected == method,
          onTap: () => controller.selectPayment(method),
        );
    }
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.iconAsset,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  iconAsset,
                  package: MembershipAssets.package,
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: MembershipPalette.titleBlack,
                      ),
                      children: [
                        TextSpan(text: title),
                        if (subtitle != null)
                          TextSpan(
                            text: subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: MembershipPalette.beanOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  selected
                      ? MembershipAssets.iconCheckSelected
                      : MembershipAssets.iconRadioUnselectedSvip,
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
  }
}
