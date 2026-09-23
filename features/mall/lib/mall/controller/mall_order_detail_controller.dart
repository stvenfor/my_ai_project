import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/auth_http_config.dart';
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

  /// 1 支付宝 2 微信 6 余额；纯积分单用 5。
  final selectedChannel = 1.obs;
  final walletBalance = '0.00'.obs;

  static const payAlipay = 1;
  static const payWeChat = 2;
  static const payPoints = 5;
  static const payBalance = 6;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  bool get needsCny {
    final a = detail.value?.amount ?? '0.00';
    return a.trim().isNotEmpty && a != '0' && a != '0.00' && a != '0.0';
  }

  bool get needsPoints => (detail.value?.totalPoints ?? 0) > 0;

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
      if (needsCny) {
        selectedChannel.value = payAlipay;
        await _loadWalletBalance();
      } else if (needsPoints) {
        selectedChannel.value = payPoints;
      }
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

  Future<void> _loadWalletBalance() async {
    try {
      AuthHttpConfig.ensureInitialized();
      final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
        '/api/v1/wallet',
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          (m) => m,
        ),
      );
      final data = result.data?.data;
      if (data != null) {
        walletBalance.value = data['balance']?.toString() ?? '0.00';
      }
    } catch (_) {
      // 余额展示失败不挡支付
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
      final channel = needsCny ? selectedChannel.value : payPoints;
      detail.value = await _repository.payOrder(
        orderId: orderId,
        paymentChannel: channel,
      );
      UiKitInitializer.toast('支付成功');
      await _loadWalletBalance();
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
      await _loadWalletBalance();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '取消失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('取消失败');
    } finally {
      acting.value = false;
    }
  }
}
