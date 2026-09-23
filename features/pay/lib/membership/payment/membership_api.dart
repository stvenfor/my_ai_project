import 'package:module_http/module_http.dart';

/// 会员订阅 BFF。
class MembershipApi {
  MembershipApi({HttpManager? http}) : _http = http ?? HttpManager.instance;

  static const mePath = '/api/v1/membership/me';
  static const buyoutPath = '/api/v1/membership/buyout';
  static const confirmPath = '/api/v1/membership/buyout/confirm';
  static const huaweiVerifyPath = '/api/v1/membership/huawei/verify';
  static const appleVerifyPath = '/api/v1/membership/apple/verify';

  final HttpManager _http;

  Future<Map<String, dynamic>> fetchMe() async {
    final result = await _http.get<ResultModel<Map<String, dynamic>>>(
      mePath,
      converter: (json) => ResultModel.fromJson(
        json,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '加载会员信息失败',
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }

  Future<Map<String, dynamic>> buyout({
    required String planId,
    required String channel,
  }) async {
    final result = await _http.post<ResultModel<Map<String, dynamic>>>(
      buyoutPath,
      data: {'plan_id': planId, 'channel': channel},
      converter: (json) => ResultModel.fromJson(
        json,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '下单失败',
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }

  Future<Map<String, dynamic>> confirmBuyout({required int orderId}) async {
    final result = await _http.post<ResultModel<Map<String, dynamic>>>(
      confirmPath,
      data: {'order_id': orderId},
      converter: (json) => ResultModel.fromJson(
        json,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '确认支付失败',
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }

  Future<Map<String, dynamic>> verifyHuawei({
    required String productId,
    required String purchaseToken,
    String purchaseOrderId = '',
    String subscriptionId = '',
    String jwsPurchaseOrder = '',
  }) async {
    final result = await _http.post<ResultModel<Map<String, dynamic>>>(
      huaweiVerifyPath,
      data: {
        'product_id': productId,
        'purchase_token': purchaseToken,
        'purchase_order_id': purchaseOrderId,
        'subscription_id': subscriptionId,
        'jws_purchase_order': jwsPurchaseOrder,
      },
      converter: (json) => ResultModel.fromJson(
        json,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '华为内购验单失败',
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }

  Future<Map<String, dynamic>> verifyApple({
    required String productId,
    required String transactionId,
    String originalTransactionId = '',
    String receiptData = '',
  }) async {
    final result = await _http.post<ResultModel<Map<String, dynamic>>>(
      appleVerifyPath,
      data: {
        'product_id': productId,
        'transaction_id': transactionId,
        'original_transaction_id': originalTransactionId,
        'receipt_data': receiptData,
      },
      converter: (json) => ResultModel.fromJson(
        json,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '苹果内购验单失败',
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }
}
