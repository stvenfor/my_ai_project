import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/model/mall_order.dart';
import 'package:module_mall/mall/model/mall_product_detail.dart';
import 'package:module_mall/mall/model/mall_product_model.dart';

/// 商城 API。身份只认 Session 头。
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
      data: {'sku_id': skuId, 'qty': qty},
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _data(result.data, '加入购物车失败');
  }

  /// 仅创建待支付订单（不支付），返回 order_id。客户端进详情完成支付。
  Future<int> createOrder({
    required int storeId,
    required int skuId,
    required int qty,
    String receiverName = '',
    String receiverPhone = '',
    String receiverAddress = '',
  }) async {
    AuthHttpConfig.ensureInitialized();
    final created = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '/api/v1/mall/orders',
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
    final orderId = (order['order_id'] as num?)?.toInt() ?? 0;
    if (orderId <= 0) {
      throw HttpRequestException(message: '下单失败：缺少订单号');
    }
    return orderId;
  }

  /// 下单并按渠道本地支付，返回订单号（兼容旧调用）。
  Future<String> buy({
    required int storeId,
    required int skuId,
    required int qty,
    required int paymentChannel,
    String receiverName = '',
    String receiverPhone = '',
    String receiverAddress = '',
  }) async {
    final orderId = await createOrder(
      storeId: storeId,
      skuId: skuId,
      qty: qty,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      receiverAddress: receiverAddress,
    );
    final paid = await payOrder(orderId: orderId, paymentChannel: paymentChannel);
    return paid.orderNo;
  }

  /// status 例：`null` 全部、`"0"` 待支付、`"1,2"` 已支付含履约、`"3,4"` 已取消含关闭。
  Future<PageResult<MallOrderListRow>> fetchOrders({
    required int page,
    int size = pageSize,
    String? status,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final query = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    final result = await HttpManager.instance.get<ResultModel<ListData<MallOrderListRow>>>(
      '/api/v1/mall/orders',
      queryParameters: query,
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        MallOrderListRow.fromJson,
      ),
    );
    final model = result.data;
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: model?.message ?? '加载订单失败',
        code: model?.code.toString(),
      );
    }
    return PageResult.fromListData(model.data!, pageSize: size);
  }

  Future<MallOrderDetail> fetchOrderDetail(int orderId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<MallOrderDetail>>(
      '/api/v1/mall/orders/$orderId',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        MallOrderDetail.fromJson,
      ),
    );
    return _data(result.data, '加载订单详情失败');
  }

  Future<MallOrderDetail> payOrder({
    required int orderId,
    required int paymentChannel,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<MallOrderDetail>>(
      '/api/v1/mall/orders/$orderId/pay',
      data: {'payment_channel': paymentChannel},
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        MallOrderDetail.fromJson,
      ),
    );
    return _data(result.data, '支付失败');
  }

  Future<void> cancelOrder(int orderId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '/api/v1/mall/orders/$orderId/cancel',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _data(result.data, '取消订单失败');
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
}
