import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/model/mall_product_detail.dart';
import 'package:module_mall/mall/repository/mall_repository.dart';
import 'package:wys_common/wys_common.dart';
import 'package:wys_router/src/route/route_path.dart';

class MallDetailController extends GetxController {
  MallDetailController({
    required this.productId,
    MallRepository? repository,
  }) : _repository = repository ?? MallRepository();

  final String productId;
  final MallRepository _repository;

  final detail = Rxn<MallProductDetail>();
  final selectedSku = Rxn<MallSkuOffer>();
  final qty = 1.obs;
  final loading = true.obs;
  final submitting = false.obs;
  final errorMessage = ''.obs;

  /// 实体下单选用的收货信息（来自地址簿 Bridge）。
  final receiverName = ''.obs;
  final receiverPhone = ''.obs;
  final receiverAddress = ''.obs;

  bool get hasAddress =>
      receiverName.value.trim().isNotEmpty &&
      receiverPhone.value.trim().isNotEmpty &&
      receiverAddress.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (productId.isEmpty) {
      loading.value = false;
      errorMessage.value = '缺少商品 ID';
      return;
    }
    loading.value = true;
    errorMessage.value = '';
    try {
      final d = await _repository.fetchDetail(productId);
      detail.value = d;
      selectedSku.value = d.skus.isEmpty ? null : d.skus.first;
      qty.value = 1;
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载详情失败' : e.message;
      detail.value = null;
    } catch (_) {
      errorMessage.value = '加载详情失败';
      detail.value = null;
    } finally {
      loading.value = false;
    }
  }

  void selectSku(MallSkuOffer sku) {
    selectedSku.value = sku;
    qty.value = 1;
  }

  void setQty(int value) {
    if (value < 1) return;
    final stock = selectedSku.value?.stockQty ?? 0;
    final d = detail.value;
    if (d != null && !d.isVirtual && stock > 0 && value > stock) {
      UiKitInitializer.toast('库存不足');
      return;
    }
    qty.value = value;
  }

  Future<void> pickAddress() async {
    WysAddressChooseBridge.beginChoose();
    await Get.toNamed(RoutePath.mineAddresses, arguments: {'choose': true});
    final book = WysAddressChooseBridge.takeChosenBook();
    if (book == null) return;
    receiverName.value = book['receiver_name']?.toString() ?? '';
    receiverPhone.value = book['receiver_phone']?.toString() ?? '';
    final full = book['full_address']?.toString() ?? '';
    receiverAddress.value = full.isNotEmpty
        ? full
        : book['detail_address']?.toString() ?? '';
  }

  Future<void> addToCart() async {
    final sku = selectedSku.value;
    if (sku == null) {
      UiKitInitializer.toast('请选择规格');
      return;
    }
    if (submitting.value) return;
    submitting.value = true;
    try {
      await _repository.addToCart(skuId: sku.skuId, qty: qty.value);
      UiKitInitializer.toast('已加入购物车');
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '加入购物车失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('加入购物车失败');
    } finally {
      submitting.value = false;
    }
  }

  Future<void> buyNow() async {
    final sku = selectedSku.value;
    final d = detail.value;
    if (sku == null || d == null) {
      UiKitInitializer.toast('请选择规格');
      return;
    }
    if (!d.isVirtual && !hasAddress) {
      await pickAddress();
      if (!hasAddress) {
        UiKitInitializer.toast('请先选择收货地址');
        return;
      }
    }
    if (submitting.value) return;
    submitting.value = true;
    try {
      final orderId = await _repository.createOrder(
        skuId: sku.skuId,
        qty: qty.value,
        receiverName: d.isVirtual ? '' : receiverName.value,
        receiverPhone: d.isVirtual ? '' : receiverPhone.value,
        receiverAddress: d.isVirtual ? '' : receiverAddress.value,
      );
      UiKitInitializer.toast('订单已创建，请在 15 分钟内支付');
      await Get.toNamed(RoutePath.mallOrderDetail, arguments: orderId);
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '下单失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('下单失败');
    } finally {
      submitting.value = false;
    }
  }
}
