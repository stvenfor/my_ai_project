import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/api/mine_http_config.dart';
import 'package:module_settings/purchase_calculator/model/purchase_calculator_models.dart';

class PurchaseCalculatorApi {
  static const productsPath = '/api/v1/purchase-calculator/products';
  static const quotePath = '/api/v1/purchase-calculator/quote';

  void _ensureHttpReady() {
    if (HttpManager.instance.isInitialized) return;
    MineHttpConfig.init(enableLog: kDebugMode, maxRetries: 3);
  }

  Future<List<FinanceProduct>> listProducts() async {
    _ensureHttpReady();
    final result = await HttpManager.instance
        .get<ResultModel<Map<String, dynamic>>>(
      productsPath,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data as Map),
      ),
    );
    final data = result.data?.data;
    final items = data?['items'];
    if (items is! List) {
      throw HttpRequestException(message: '产品列表为空');
    }
    return items
        .whereType<Map>()
        .map((e) => FinanceProduct.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PurchaseQuote> quote({
    required String mode,
    required double barePrice,
    double? taxablePrice,
    int? productId,
    double? downPayment,
    int? termMonths,
    bool disableCommercial = false,
  }) async {
    _ensureHttpReady();
    final body = <String, dynamic>{
      'mode': mode,
      'bare_price': barePrice,
      'disable_commercial': disableCommercial,
      if (taxablePrice != null) 'taxable_price': taxablePrice,
      if (productId != null) 'product_id': productId,
      if (downPayment != null) 'down_payment': downPayment,
      if (termMonths != null) 'term_months': termMonths,
    };
    final result = await HttpManager.instance
        .post<ResultModel<PurchaseQuote>>(
      quotePath,
      data: body,
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        PurchaseQuote.fromJson,
      ),
    );
    final quote = result.data?.data;
    if (quote == null) {
      throw HttpRequestException(message: '报价结果为空');
    }
    return quote;
  }
}
