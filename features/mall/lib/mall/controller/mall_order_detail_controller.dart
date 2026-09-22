import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/model/mall_order.dart';
import 'package:module_mall/mall/repository/mall_repository.dart';

class MallOrderDetailController extends GetxController {
  MallOrderDetailController({
    required this.orderId,
    MallRepository? repository,
  }) : _repository = repository ?? MallRepository();

  final int orderId;
  final MallRepository _repository;

  final detail = Rxn<MallOrderDetail>();
  final loading = true.obs;
  final acting = false.obs;
  final errorMessage = ''.obs;

  static const _payAlipay = 1;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (orderId <= 0) {
      loading.value = false;
      errorMessage.value = '缺少订单 ID';
      return;
    }
    loading.value = true;
    errorMessage.value = '';
    try {
      detail.value = await _repository.fetchOrderDetail(orderId);
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载订单失败' : e.message;
      detail.value = null;
    } catch (_) {
      errorMessage.value = '加载订单失败';
      detail.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> copyOrderNo(String orderNo) async {
    if (orderNo.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: orderNo));
    UiKitInitializer.toast('订单号已复制');
  }

  Future<void> onPayExpired() async {
    UiKitInitializer.toast('支付已超时，订单已取消');
    await load();
  }

  Future<void> pay() async {
    if (acting.value) return;
    acting.value = true;
    try {
      detail.value = await _repository.payOrder(
        orderId: orderId,
        paymentChannel: _payAlipay,
      );
      UiKitInitializer.toast('支付成功');
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '支付失败' : e.message);
      await load();
    } catch (_) {
      UiKitInitializer.toast('支付失败');
      await load();
    } finally {
      acting.value = false;
    }
  }

  Future<void> cancel() async {
    if (acting.value) return;
    acting.value = true;
    try {
      await _repository.cancelOrder(orderId);
      UiKitInitializer.toast('已取消');
      await load();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '取消失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('取消失败');
    } finally {
      acting.value = false;
    }
  }
}
