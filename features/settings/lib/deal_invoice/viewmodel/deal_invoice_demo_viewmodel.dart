import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/deal_invoice/api/deal_invoice_api.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';
import 'package:wys_router/src/route/route_path.dart';

class DealInvoiceTabState {
  final items = <DealInvoiceItem>[].obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int page = 1;
}

class DealInvoiceDemoViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  DealInvoiceDemoViewModel({DealInvoiceApi? api}) : _api = api ?? DealInvoiceApi();

  final DealInvoiceApi _api;
  late final TabController tabController;

  final summary = Rxn<DealInvoiceSummary>();
  final tabStates = List.generate(
    DealInvoiceTab.values.length,
    (_) => DealInvoiceTabState(),
  );

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: DealInvoiceTab.values.length,
      vsync: this,
    );
    refreshSummary();
    for (var i = 0; i < DealInvoiceTab.values.length; i++) {
      loadInitial(i);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  DealInvoiceTab tabAt(int index) => DealInvoiceTab.values[index];

  Future<void> refreshSummary() async {
    try {
      summary.value = await _api.fetchSummary();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toastError(e.message);
    } catch (_) {
      UiKitInitializer.toastError('加载摘要失败');
    }
  }

  Future<void> loadInitial(int tabIndex) {
    final state = tabStates[tabIndex];
    state.page = 1;
    state.hasMore.value = true;
    return _load(tabIndex, reset: true);
  }

  Future<void> refreshTab(int tabIndex) async {
    final state = tabStates[tabIndex];
    if (state.isRefreshing.value) return;
    state.isRefreshing.value = true;
    state.page = 1;
    state.hasMore.value = true;
    try {
      await Future.wait([
        refreshSummary(),
        _load(tabIndex, reset: true),
      ]);
    } finally {
      state.isRefreshing.value = false;
    }
  }

  Future<void> loadMore(int tabIndex) async {
    final state = tabStates[tabIndex];
    if (state.isLoadingMore.value || !state.hasMore.value) return;
    state.isLoadingMore.value = true;
    state.page += 1;
    try {
      await _load(tabIndex, reset: false);
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  Future<void> _load(int tabIndex, {required bool reset}) async {
    final state = tabStates[tabIndex];
    final tab = tabAt(tabIndex);
    try {
      final result = await _api.fetchList(tab: tab, page: state.page);
      if (reset) {
        state.items.assignAll(result.list);
      } else {
        state.items.addAll(result.list);
      }
      state.hasMore.value = result.hasMore;
    } on HttpRequestException catch (e) {
      if (reset) state.items.clear();
      state.hasMore.value = false;
      UiKitInitializer.toastError(e.message);
    } catch (_) {
      if (reset) state.items.clear();
      state.hasMore.value = false;
      UiKitInitializer.toastError('加载列表失败');
    }
  }

  Future<void> onUploadTap() async {
    await Get.toNamed(RoutePath.dealInvoiceUpload, arguments: const DealInvoiceUploadArgs(
      scene: DealInvoiceUploadScene.create,
    ));
    await _reloadAll();
  }

  Future<void> onItemTap(DealInvoiceItem item) async {
    await Get.toNamed(
      RoutePath.dealInvoiceUpload,
      arguments: DealInvoiceUploadArgs(
        scene: DealInvoiceUploadScene.detail,
        item: item,
      ),
    );
    await _reloadAll();
  }

  Future<void> onProcessTap(DealInvoiceItem item) async {
    await Get.toNamed(
      RoutePath.dealInvoiceUpload,
      arguments: DealInvoiceUploadArgs(
        scene: DealInvoiceUploadScene.reupload,
        item: item,
      ),
    );
    await _reloadAll();
  }

  Future<void> _reloadAll() async {
    await refreshSummary();
    for (var i = 0; i < DealInvoiceTab.values.length; i++) {
      await loadInitial(i);
    }
  }
}
