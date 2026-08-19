import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_pay/membership/mock/membership_mock_data.dart';
import 'package:module_pay/membership/model/membership_models.dart';

class MembershipRenewController extends GetxController {
  final selectedTier = MembershipTier.svip.obs;
  final selectedPlanId = 'svip_12m'.obs;
  final useDeduction = true.obs;
  final paymentMethod = PaymentMethodType.wechat.obs;
  final agreedToTerms = false.obs;
  final redPacketCountdown = MembershipMockData.redPacketCountdown.obs;
  final showCollapsedNav = false.obs;

  final scrollController = ScrollController();

  Timer? _countdownTimer;
  int _redPacketSeconds = 2 * 3600 + 32 * 60 + 59;
  double _navCollapseThreshold = 106;

  MembershipUserProfile get profile => MembershipMockData.userProfile;

  List<MembershipPlan> get currentPlans =>
      MembershipMockData.plansFor(selectedTier.value);

  MembershipPlan get selectedPlan => currentPlans.firstWhere(
        (plan) => plan.id == selectedPlanId.value,
        orElse: () => currentPlans.first,
      );

  MembershipPromoBanner get currentPromo =>
      MembershipMockData.promoFor(selectedTier.value);

  double get finalPrice {
    var price = selectedPlan.price;
    if (useDeduction.value) {
      price -= MembershipMockData.deductionAmount;
    }
    if (paymentMethod.value == PaymentMethodType.wechat) {
      price -= MembershipMockData.beanBalance;
    }
    return price < 0 ? 0 : double.parse(price.toStringAsFixed(2));
  }

  bool get showAgreementCheckbox =>
      selectedTier.value == MembershipTier.aiSvip;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _startCountdown();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  void bindNavCollapseThreshold(double threshold) {
    if (_navCollapseThreshold == threshold) return;
    _navCollapseThreshold = threshold;
    _onScroll();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final show = scrollController.offset >= _navCollapseThreshold;
    if (showCollapsedNav.value != show) {
      showCollapsedNav.value = show;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_redPacketSeconds <= 0) return;
      _redPacketSeconds--;
      final hours = _redPacketSeconds ~/ 3600;
      final minutes = (_redPacketSeconds % 3600) ~/ 60;
      final seconds = _redPacketSeconds % 60;
      redPacketCountdown.value =
          '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    });
  }

  void selectTier(MembershipTier tier) {
    if (selectedTier.value == tier) return;
    selectedTier.value = tier;
    useDeduction.value = tier == MembershipTier.svip;
    agreedToTerms.value = false;
    final plans = MembershipMockData.plansFor(tier);
    selectedPlanId.value = plans.first.id;
  }

  void selectPlan(String planId) {
    selectedPlanId.value = planId;
  }

  void toggleDeduction() {
    useDeduction.value = !useDeduction.value;
  }

  void selectPayment(PaymentMethodType method) {
    paymentMethod.value = method;
  }

  void toggleAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  void openCustomerService() {
    UiKitInitializer.toast('客服帮助（开发中）');
  }

  void renewNow() {
    if (showAgreementCheckbox && !agreedToTerms.value) {
      UiKitInitializer.toast('请先阅读并同意会员协议');
      return;
    }
    UiKitInitializer.toast(
      'Mock 续费 ¥${finalPrice.toStringAsFixed(2)}（${selectedPlan.title}）',
    );
  }
}
