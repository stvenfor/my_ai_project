import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/api/mall_api.dart';
import 'package:module_mall/mall/model/mall_product_detail.dart';
import 'package:module_mall/mall/model/mall_product_model.dart';

class MallRepository {
  MallRepository({MallApi? api}) : _api = api ?? MallApi();

  final MallApi _api;

  /// 默认门店与种子数据一致（store_id=1）。
  static const defaultStoreId = 1;

  Future<PageResult<MallProductCardModel>> fetchPage({
    int storeId = defaultStoreId,
    required int page,
    int size = MallApi.pageSize,
  }) {
    return _api.fetchShelfPage(storeId: storeId, page: page, size: size);
  }

  Future<MallProductDetail> fetchDetail(
    String productId, {
    int storeId = defaultStoreId,
  }) {
    return _api.fetchDetail(storeId: storeId, productId: productId);
  }

  Future<void> addToCart({required int skuId, required int qty}) {
    return _api.addToCart(skuId: skuId, qty: qty);
  }

  Future<String> buy({
    required int skuId,
    required int qty,
    required int paymentChannel,
    int storeId = defaultStoreId,
    String receiverName = '',
    String receiverPhone = '',
    String receiverAddress = '',
  }) {
    return _api.buy(
      storeId: storeId,
      skuId: skuId,
      qty: qty,
      paymentChannel: paymentChannel,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      receiverAddress: receiverAddress,
    );
  }
}
