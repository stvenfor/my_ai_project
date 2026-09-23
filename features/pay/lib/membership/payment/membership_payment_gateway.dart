import 'package:flutter/services.dart';
import 'package:module_http/module_http.dart';
import 'package:module_pay/membership/payment/apple_iap_bridge.dart';
import 'package:module_pay/membership/payment/huawei_iap_bridge.dart';
import 'package:module_pay/membership/payment/membership_api.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:wys_login_share_pay/wys_login_share_pay.dart';

/// 会员开通/续费：余额/微信/支付宝买断；华为/苹果自动续期。
class MembershipPaymentGateway {
  MembershipPaymentGateway({
    HttpManager? http,
    MembershipApi? api,
  })  : _http = http ?? HttpManager.instance,
        _api = api ?? MembershipApi(http: http);

  static const prepayPath = '/api/v1/payments/prepay';

  final HttpManager _http;
  final MembershipApi _api;

  MembershipApi get api => _api;

  Future<WysPaymentResult> payBuyout({
    required PaymentMethodType method,
    required String planId,
  }) async {
    final channel = switch (method) {
      PaymentMethodType.wechat => 'wechat',
      PaymentMethodType.alipay => 'alipay',
      PaymentMethodType.balance => 'balance',
      PaymentMethodType.huawei || PaymentMethodType.apple => '',
    };
    if (channel.isEmpty) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '请使用对应内购通道',
      );
    }

    try {
      final buyout = await _api.buyout(planId: planId, channel: channel);
      final status = '${buyout['status'] ?? ''}';
      if (status == 'paid') {
        return const WysPaymentResult(status: WysPaymentStatus.success);
      }

      final orderId = (buyout['order_id'] as num?)?.toInt() ?? 0;
      final params = buyout['prepay_params'] is Map
          ? Map<String, dynamic>.from(buyout['prepay_params'] as Map)
          : <String, dynamic>{};
      final payMethod = method == PaymentMethodType.wechat
          ? WysPaymentMethod.wechat
          : WysPaymentMethod.alipay;

      if (method == PaymentMethodType.wechat &&
          !WysWechatConfig.isConfigured) {
        return const WysPaymentResult(
          status: WysPaymentStatus.launchFailed,
          message: '请先在 WysWechatConfig 填写微信 AppID / Universal Link',
        );
      }

      final sdk = await WysLoginSharePayService.instance.pay(
        method: payMethod,
        params: params,
      );
      if (!sdk.isSuccess) {
        return sdk;
      }
      if (orderId > 0) {
        await _api.confirmBuyout(orderId: orderId);
      }
      return const WysPaymentResult(status: WysPaymentStatus.success);
    } on HttpRequestException catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.toString(),
      );
    }
  }

  Future<WysPaymentResult> payHuawei({
    required String huaweiProductId,
  }) async {
    if (!HuaweiIapBridge.isOhos) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '华为内购仅支持鸿蒙端',
      );
    }
    if (huaweiProductId.isEmpty) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '缺少华为商品 ID',
      );
    }
    try {
      final purchase = await HuaweiIapBridge.createPurchase(
        productId: huaweiProductId,
      );
      final verified = await _api.verifyHuawei(
        productId: purchase.productId,
        purchaseToken: purchase.purchaseToken,
        purchaseOrderId: purchase.purchaseOrderId,
        subscriptionId: purchase.subscriptionId,
        jwsPurchaseOrder: purchase.jwsPurchaseOrder,
      );
      final finish = verified['finish_purchase'] == true;
      if (finish) {
        try {
          await HuaweiIapBridge.finishPurchase(
            productId: purchase.productId,
            purchaseToken: purchase.purchaseToken,
            purchaseOrderId: purchase.purchaseOrderId,
          );
        } catch (_) {}
      }
      return const WysPaymentResult(status: WysPaymentStatus.success);
    } on PlatformException catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.message ?? e.code,
        code: e.code,
      );
    } on HttpRequestException catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.toString(),
      );
    }
  }

  Future<WysPaymentResult> payApple({
    required String appleProductId,
  }) async {
    if (!AppleIapBridge.isIOS) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '苹果内购仅支持 iOS',
      );
    }
    if (appleProductId.isEmpty) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '缺少苹果商品 ID',
      );
    }
    try {
      final purchase = await AppleIapBridge.buySubscription(
        productId: appleProductId,
      );
      final verified = await _api.verifyApple(
        productId: purchase.productId,
        transactionId: purchase.transactionId,
        originalTransactionId: purchase.originalTransactionId,
        receiptData: purchase.receiptData,
      );
      if (verified['complete_purchase'] == true) {
        try {
          await AppleIapBridge.completePurchase(
            transactionId: purchase.transactionId,
          );
        } catch (_) {}
      }
      return const WysPaymentResult(status: WysPaymentStatus.success);
    } on PlatformException catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.message ?? e.code,
        code: e.code,
      );
    } on HttpRequestException catch (e) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('已取消')) {
        return const WysPaymentResult(status: WysPaymentStatus.cancelled);
      }
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: msg,
      );
    }
  }

  Future<void> restoreHuaweiPurchases() async {
    if (!HuaweiIapBridge.isOhos) return;
    try {
      final list = await HuaweiIapBridge.queryPurchases();
      for (final p in list) {
        if (p.purchaseToken.isEmpty || p.productId.isEmpty) continue;
        final verified = await _api.verifyHuawei(
          productId: p.productId,
          purchaseToken: p.purchaseToken,
          purchaseOrderId: p.purchaseOrderId,
          subscriptionId: p.subscriptionId,
          jwsPurchaseOrder: p.jwsPurchaseOrder,
        );
        if (verified['finish_purchase'] == true) {
          await HuaweiIapBridge.finishPurchase(
            productId: p.productId,
            purchaseToken: p.purchaseToken,
            purchaseOrderId: p.purchaseOrderId,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> restoreApplePurchases() async {
    if (!AppleIapBridge.isIOS) return;
    try {
      await AppleIapBridge.restorePurchases();
    } catch (_) {}
  }
}
