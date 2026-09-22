import 'package:get/get.dart';
import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/model/mall_product_detail.dart';
import 'package:module_mall/mall/model/mall_product_model.dart';

/// GET /api/v1/mall/stores/:store_id/products?page=&size=&user_id=
class MallApi {
  static const pageSize = 10;

  Future<PageResult<MallProductCardModel>> fetchShelfPage({
    required int storeId,
    required int page,
    int size = pageSize,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<ListData<MallProductCardModel>>>(
      '/api/v1/mall/stores/$storeId/products',
      queryParameters: {
        'page': page,
        'size': size,
        ..._userIdQuery(),
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        MallProductCardModel.fromJson,
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '加载商品失败',
        code: model?.code.toString(),
      );
    }
    return PageResult.fromListData(model.data!, pageSize: size);
  }

  Future<MallProductDetail> fetchDetail({
    required int storeId,
    required String productId,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<MallProductDetail>>(
      '/api/v1/mall/stores/$storeId/products/$productId',
      queryParameters: _userIdQuery(),
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        MallProductDetail.fromJson,
      ),
    );
    return _data(result.data, '加载详情失败');
  }

  Future<void> addToCart({required int skuId, required int qty}) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '/api/v1/mall/cart',
      queryParameters: _userIdQuery(),
      data: {'sku_id': skuId, 'qty': qty},
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _data(result.data, '加入购物车失败');
  }

  /// 下单并按渠道本地支付，返回订单号。
  Future<String> buy({
    required int storeId,
    required int skuId,
    required int qty,
    required int paymentChannel,
    String receiverName = '',
    String receiverPhone = '',
    String receiverAddress = '',
  }) async {
    AuthHttpConfig.ensureInitialized();
    final created = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '/api/v1/mall/orders',
      queryParameters: _userIdQuery(),
      data: {
        'idempotency_key': '$skuId-${DateTime.now().microsecondsSinceEpoch}',
        'store_id': storeId,
        'lines': [
          {'sku_id': skuId, 'qty': qty},
        ],
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'receiver_address': receiverAddress,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    final order = _data(created.data, '下单失败')['order'] as Map<String, dynamic>? ?? const {};
    final orderId = order['order_id'];
    final orderNo = order['order_no']?.toString() ?? '';
    final paid = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '/api/v1/mall/orders/$orderId/pay',
      queryParameters: _userIdQuery(),
      data: {'payment_channel': paymentChannel},
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _data(paid.data, '支付失败');
    return orderNo;
  }

  static T _data<T>(ResultModel<T>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data as T;
  }

  static Map<String, dynamic> _userIdQuery() {
    if (!Get.isRegistered<UserService>()) return const {};
    final id = Get.find<UserService>().currentUser.value?.id.trim() ?? '';
    if (id.isEmpty) return const {};
    return {'user_id': id};
  }
}
