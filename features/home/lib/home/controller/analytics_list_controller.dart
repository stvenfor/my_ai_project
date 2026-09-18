import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/model/analytics_record_model.dart';
import 'package:module_home/home/repository/analytics_repository.dart';

class AnalyticsListController extends GetxController {
  AnalyticsListController({AnalyticsRepository? repository})
      : _repository = repository ?? Get.find<AnalyticsRepository>();

  final AnalyticsRepository _repository;

  final items = <AnalyticsRecordModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final currentPage = 0.obs;
  final total = 0.obs;

  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    errorMessage.value = null;
    currentPage.value = 0;
    try {
      final result = await _repository.fetchPage(page: 1, pageSize: pageSize);
      items.assignAll(result.items);
      total.value = result.total;
      hasMore.value = result.hasMore;
      currentPage.value = result.items.isEmpty ? 0 : 1;
    } catch (error) {
      errorMessage.value = formatAnalyticsLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    if (!AuthSession.isLoggedIn) return;
    errorMessage.value = null;
    try {
      final result = await _repository.fetchPage(page: 1, pageSize: pageSize);
      items.assignAll(result.items);
      total.value = result.total;
      hasMore.value = result.hasMore;
      currentPage.value = result.items.isEmpty ? 0 : 1;
    } catch (error) {
      errorMessage.value = formatAnalyticsLoadError(error);
      UiKitInitializer.toastError('刷新失败');
    }
  }

  Future<void> loadMore() async {
    if (!AuthSession.isLoggedIn || isLoadingMore.value || !hasMore.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final next = currentPage.value + 1;
      final result =
          await _repository.fetchPage(page: next, pageSize: pageSize);
      if (result.items.isEmpty) {
        hasMore.value = false;
      } else {
        items.addAll(result.items);
        currentPage.value = next;
        total.value = result.total;
        hasMore.value = result.hasMore;
      }
    } catch (_) {
      UiKitInitializer.toastError('加载更多失败');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
