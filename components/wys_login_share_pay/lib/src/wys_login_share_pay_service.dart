import 'package:tobias/tobias.dart';

import 'wys_payment_models.dart';
import 'wys_wechat_models.dart';
import 'wys_wechat_service.dart';

class WysLoginSharePayService {
  WysLoginSharePayService._();

  static final WysLoginSharePayService instance = WysLoginSharePayService._();

  final Tobias _tobias = Tobias();

  Future<WysPaymentResult> pay({
    required WysPaymentMethod method,
    required Map<String, dynamic> params,
    void Function()? onLaunched,
  }) {
    return switch (method) {
      WysPaymentMethod.wechat => _payWithWechat(params, onLaunched),
      WysPaymentMethod.alipay => _payWithAlipay(params, onLaunched),
    };
  }

  void cancelPendingPayment(WysPaymentMethod method) {
    if (method == WysPaymentMethod.wechat) {
      WysWechatService.instance.cancelPendingPayment();
    }
  }

  Future<WysPaymentResult> _payWithWechat(
    Map<String, dynamic> params,
    void Function()? onLaunched,
  ) async {
    final result = await WysWechatService.instance.pay(
      params,
      onLaunched: onLaunched,
    );
    return WysPaymentResult(
      status: switch (result.status) {
        WysWechatStatus.success => WysPaymentStatus.success,
        WysWechatStatus.cancelled => WysPaymentStatus.cancelled,
        WysWechatStatus.notInstalled => WysPaymentStatus.notInstalled,
        WysWechatStatus.launchFailed => WysPaymentStatus.launchFailed,
        WysWechatStatus.sdkError => WysPaymentStatus.sdkError,
        WysWechatStatus.timeout => WysPaymentStatus.timeout,
      },
      code: result.code?.toString(),
      message: result.message,
    );
  }

  Future<WysPaymentResult> _payWithAlipay(
    Map<String, dynamic> params,
    void Function()? onLaunched,
  ) async {
    final orderInfo = (params['body'] ?? params['orderInfo'])?.toString() ?? '';
    if (orderInfo.isEmpty) {
      return const WysPaymentResult(
        status: WysPaymentStatus.launchFailed,
        message: '支付宝订单信息异常',
      );
    }
    try {
      final payment = _tobias.pay(orderInfo);
      onLaunched?.call();
      final response = await payment;
      final raw = Map<String, dynamic>.from(response);
      final code = raw['resultStatus']?.toString() ?? '';
      final status = switch (code) {
        '9000' => WysPaymentStatus.success,
        '6001' => WysPaymentStatus.cancelled,
        '8000' || '6004' => WysPaymentStatus.processing,
        _ => WysPaymentStatus.sdkError,
      };
      return WysPaymentResult(
        status: status,
        code: code,
        message: raw['memo']?.toString(),
        rawResult: raw,
      );
    } catch (error) {
      return WysPaymentResult(
        status: WysPaymentStatus.sdkError,
        message: error.toString(),
      );
    }
  }
}
