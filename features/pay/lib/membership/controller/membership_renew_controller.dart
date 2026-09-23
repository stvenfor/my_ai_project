import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_pay/membership/mock/membership_mock_data.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/payment/apple_iap_bridge.dart';
import 'package:module_pay/membership/payment/huawei_iap_bridge.dart';
import 'package:module_pay/membership/payment/membership_payment_gateway.dart';
import 'package:wys_login_share_pay/wys_login_share_pay.dart';

class MembershipRenewController extends GetxController {
  final selectedTier = MembershipTier.svip.obs;
  final selectedPlanId = 'svip_1m'.obs;
  final useDeduction = false.obs;
  final paymentMethod = PaymentMethodType.wechat.obs;
  final agreedToTerms = false.obs;
  final redPacketCountdown = MembershipMockData.redPacketCountdown.obs;
  final showCollapsedNav = false.obs;
  final ctaLabel = '开通'.obs;
  final catalogPlans = <MembershipPlan>[].obs;
  final walletBalance = '0.00'.obs;

  final scrollController = ScrollController();
  final paying = false.obs;
  final loadingMe = false.obs;

  Timer? _countdownTimer;
  int _redPacketSeconds = 2 * 3600 + 32 * 60 + 59;
  double _navCollapseThreshold = 106;
  final _gateway = MembershipPaymentGateway();

  MembershipUserProfile get profile => MembershipMockData.userProfile;

  List<MembershipPlan> get currentPlans {
    final fromServer = catalogPlans
        .where((p) => p.tier == selectedTier.value)
        .toList();
    if (fromServer.isNotEmpty) return fromServer;
    return MembershipMockData.plansFor(selectedTier.value);
  }

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
    return price < 0 ? 0 : double.parse(price.toStringAsFixed(2));
  }

  bool get showAgreementCheckbox =>
      selectedTier.value == MembershipTier.aiSvip ||
      paymentMethod.value == PaymentMethodType.huawei ||
      paymentMethod.value == PaymentMethodType.apple;

  List<PaymentMethodType> get availablePaymentMethods {
    if (HuaweiIapBridge.isOhos) {
      return const [
        PaymentMethodType.wechat,
        PaymentMethodType.alipay,
        PaymentMethodType.balance,
        PaymentMethodType.huawei,
      ];
    }
    if (AppleIapBridge.isIOS) {
      return const [
        PaymentMethodType.wechat,
        PaymentMethodType.alipay,
        PaymentMethodType.balance,
        PaymentMethodType.apple,
      ];
    }
    return const [
      PaymentMethodType.wechat,
      PaymentMethodType.alipay,
      PaymentMethodType.balance,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _startCountdown();
    if (!availablePaymentMethods.contains(paymentMethod.value)) {
      paymentMethod.value = availablePaymentMethods.first;
    }
    unawaited(refreshMe());
    unawaited(_gateway.restoreHuaweiPurchases());
    unawaited(_gateway.restoreApplePurchases());
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshMe() async {
    loadingMe.value = true;
    try {
      final me = await _gateway.api.fetchMe();
      final catalog = me['catalog'];
      if (catalog is List) {
        catalogPlans.assignAll(
          catalog
              .whereType<Map>()
              .map((e) => MembershipPlan.fromCatalogJson(
                    Map<String, dynamic>.from(e),
                  ))
              .where((p) => p.id.isNotEmpty)
              .toList(),
        );
      }
      final ents = me['entitlements'];
      if (ents is List) {
        final tierKey =
            selectedTier.value == MembershipTier.svip ? 'svip' : 'ai_svip';
        for (final raw in ents.whereType<Map>()) {
          if ('${raw['tier']}' == tierKey) {
            ctaLabel.value = '${raw['cta'] ?? '开通'}';
            break;
          }
        }
      }
    } catch (_) {
      // 保持本地 mock 目录
    } finally {
      loadingMe.value = false;
    }
    try {
      final result = await HttpManager.instance.get(
        '/api/v1/wallet',
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => data is Map
              ? Map<String, dynamic>.from(data)
              : <String, dynamic>{},
        ),
      );
      final model = result.data;
      if (model != null && model.isSuccess && model.data != null) {
        walletBalance.value = '${model.data!['balance'] ?? '0.00'}';
      }
    } catch (_) {}
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
    useDeduction.value = false;
    agreedToTerms.value = false;
    final plans = currentPlans;
    selectedPlanId.value = plans.first.id;
    unawaited(refreshMe());
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

  Future<void> renewNow() async {
    if (showAgreementCheckbox && !agreedToTerms.value) {
      UiKitInitializer.toast('请先阅读并同意会员协议');
      return;
    }
    if (paying.value) return;

    paying.value = true;
    try {
      final WysPaymentResult result;
      if (paymentMethod.value == PaymentMethodType.huawei) {
        result = await _gateway.payHuawei(
          huaweiProductId: selectedPlan.huaweiProductId,
        );
      } else if (paymentMethod.value == PaymentMethodType.apple) {
        result = await _gateway.payApple(
          appleProductId: selectedPlan.appleProductId,
        );
      } else {
        result = await _gateway.payBuyout(
          method: paymentMethod.value,
          planId: selectedPlan.id,
        );
      }
      if (result.isSuccess) {
        UiKitInitializer.toast('${ctaLabel.value}成功');
        await refreshMe();
      } else if (result.isCancelled) {
        UiKitInitializer.toast('已取消支付');
      } else if (result.isProcessing) {
        UiKitInitializer.toast('支付处理中，请稍后确认');
      } else {
        UiKitInitializer.toast(
          result.message?.isNotEmpty == true
              ? result.message!
              : '支付失败（${result.status.name}）',
        );
      }
    } finally {
      paying.value = false;
    }
  }
}
