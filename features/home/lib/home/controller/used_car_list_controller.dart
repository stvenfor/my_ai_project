import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_home/home/repository/used_car_order_repository.dart';

class UsedCarListController extends GetxController {
  UsedCarListController({UsedCarOrderRepository? repository})
      : _repository = repository ?? Get.find<UsedCarOrderRepository>();

  final UsedCarOrderRepository _repository;

  final summary = Rxn<UsedCarOrderSummary>();
  final items = <UsedCarOrderItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final currentPage = 1.obs;
  final statusTab = UsedCarStatusTab.all.obs;
  final kindFilter = UsedCarKindFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    errorMessage.value = null;
    currentPage.value = 1;
    try {
      await _loadSummary();
      final result = await _repository.fetchPage(
        statusTab: statusTab.value,
        kindFilter: kindFilter.value,
        page: 1,
      );
      items.assignAll(result.list);
      hasMore.value = result.hasMore;
      currentPage.value = result.list.isEmpty ? 1 : 2;
    } catch (error) {
      errorMessage.value = formatTransactionLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    if (!AuthSession.isLoggedIn) return;
    errorMessage.value = null;
    try {
      await _loadSummary();
      final result = await _repository.fetchPage(
        statusTab: statusTab.value,
        kindFilter: kindFilter.value,
        page: 1,
      );
      items.assignAll(result.list);
      hasMore.value = result.hasMore;
      currentPage.value = result.list.isEmpty ? 1 : 2;
    } catch (error) {
      errorMessage.value = formatTransactionLoadError(error);
      UiKitInitializer.toastError('刷新失败');
    }
  }

  Future<void> loadMore() async {
    if (!AuthSession.isLoggedIn || isLoadingMore.value || !hasMore.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final page = currentPage.value;
      final result = await _repository.fetchPage(
        statusTab: statusTab.value,
        kindFilter: kindFilter.value,
        page: page,
      );
      if (result.list.isEmpty) {
        hasMore.value = false;
      } else {
        items.addAll(result.list);
        currentPage.value = page + 1;
        hasMore.value = result.hasMore;
      }
    } catch (_) {
      UiKitInitializer.toastError('加载更多失败');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> setStatusTab(UsedCarStatusTab tab) async {
    if (statusTab.value == tab) return;
    statusTab.value = tab;
    await loadInitial();
  }

  Future<void> setKindFilter(UsedCarKindFilter kind) async {
    if (kindFilter.value == kind) return;
    kindFilter.value = kind;
    await loadInitial();
  }

  Future<void> _loadSummary() async {
    try {
      summary.value = await _repository.fetchSummary();
    } catch (_) {
      // 列表仍可用
    }
  }
}
