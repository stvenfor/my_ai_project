import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_page_layout.dart';
import 'package:module_common_ui/layout/app_page_scaffold.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';
import 'package:module_pay/membership/widgets/membership_deduction_row.dart';
import 'package:module_pay/membership/widgets/membership_feature_section.dart';
import 'package:module_pay/membership/widgets/membership_header.dart';
import 'package:module_pay/membership/widgets/membership_payment_methods.dart';
import 'package:module_pay/membership/widgets/membership_plan_carousel.dart';
import 'package:module_pay/membership/widgets/membership_promo_banner.dart';
import 'package:module_pay/membership/widgets/membership_renew_bar.dart';
import 'package:module_pay/membership/widgets/membership_tier_tabs.dart';

class MembershipRenewPage extends GetView<MembershipRenewController> {
  const MembershipRenewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.fullBleed,
      backgroundColor: MembershipPalette.pageBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: MembershipHeader()),
              SliverToBoxAdapter(
                child: Container(
                  color: MembershipPalette.cardWhite,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MembershipTierTabs(),
                      SizedBox(height: 16),
                      MembershipPlanCarousel(),
                      MembershipPromoBanner(),
                      MembershipDeductionRow(),
                      MembershipPaymentMethods(),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: MembershipFeatureSection()),
              SliverToBoxAdapter(
                child: SizedBox(height: 180 + MediaQuery.paddingOf(context).bottom),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MembershipRenewBar(),
          ),
        ],
      ),
    );
  }
}
