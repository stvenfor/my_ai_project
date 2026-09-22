import 'package:get/get.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/model/mall_order.dart';
import 'package:module_mall/mall/repository/mall_repository.dart';
import 'package:wys_router/src/route/route_path.dart';

enum MallOrderTab { all, unpaid, paid, cancelled }

class MallOrdersController extends GetxController {
  MallOrdersController({MallRepository? repository})
      : _repository = repository ?? MallRepository();

  final MallRepository _repository;

  final tab = MallOrderTab.all.obs;
  final items = <MallOrderListRow>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final errorMessage = ''.obs;
  final hasMore = true.obs;

  int _page = 1;

  String? get _statusQuery {
    switch (tab.value) {
      case MallOrderTab.all:
        return null;
      case MallOrderTab.unpaid:
        return '0';
      case MallOrderTab.paid:
        return '1,2';
      case MallOrderTab.cancelled:
        return '3,4';
    }
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> switchTab(MallOrderTab next) async {
    if (tab.value == next) return;
    tab.value = next;
    await load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = '';
    _page = 1;
    try {
      final page = await _repository.fetchOrders(
        page: 1,
        status: _statusQuery,
      );
      items.assignAll(page.list);
      _page = 1;
      hasMore.value = page.hasMore;
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载订单失败' : e.message;
      items.clear();
      hasMore.value = false;
    } catch (_) {
      errorMessage.value = '加载订单失败';
      items.clear();
      hasMore.value = false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || loadingMore.value || loading.value) return;
    loadingMore.value = true;
    try {
      final next = _page + 1;
      final page = await _repository.fetchOrders(
        page: next,
        status: _statusQuery,
      );
      items.addAll(page.list);
      _page = next;
      hasMore.value = page.hasMore;
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载更多失败' : e.message;
    } catch (_) {
      errorMessage.value = '加载更多失败';
    } finally {
      loadingMore.value = false;
    }
  }

  void openDetail(MallOrderListRow row) {
    Get.toNamed(RoutePath.mallOrderDetail, arguments: row.orderId);
  }
}
