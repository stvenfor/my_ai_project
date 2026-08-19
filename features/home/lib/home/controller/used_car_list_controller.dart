import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_home/home/model/transaction_model.dart';
import 'package:module_common_ui/module_common_ui.dart';

class UsedCarListController extends GetxController {
  UsedCarListController({TransactionRepository? repository})
      : _repository = repository ?? Get.find<TransactionRepository>();

  final TransactionRepository _repository;

  final items = <TransactionModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  final currentPage = 0.obs;

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
      final result = await _repository.fetchPage(page: 0);
      items.assignAll(result.list);
      hasMore.value = result.hasMore;
      currentPage.value = result.list.isEmpty ? 0 : 1;
    } catch (error) {
      errorMessage.value = formatTransactionLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    if (!AuthSession.isLoggedIn) return;
    errorMessage.value = null;
    try {
      final result = await _repository.fetchPage(page: 0);
      items.assignAll(result.list);
      hasMore.value = result.hasMore;
      currentPage.value = result.list.isEmpty ? 0 : 1;
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
      final result = await _repository.fetchPage(page: page);
      if (result.list.isEmpty) {
        hasMore.value = false;
      } else {
        items.addAll(result.list);
        currentPage.value = page + 1;
        hasMore.value = result.hasMore;
      }
    } catch (error) {
      UiKitInitializer.toastError('加载更多失败');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
