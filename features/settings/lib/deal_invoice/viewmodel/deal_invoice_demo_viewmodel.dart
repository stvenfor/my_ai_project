import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/deal_invoice/mock/deal_invoice_mock_repository.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';

class DealInvoiceTabState {
  final items = <DealInvoiceItem>[].obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int page = 0;
}

class DealInvoiceDemoViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;

  final stats = DealInvoiceStats.demo.obs;
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

  Future<void> loadInitial(int tabIndex) {
    final state = tabStates[tabIndex];
    state.page = 0;
    state.hasMore.value = true;
    return _load(tabIndex, reset: true);
  }

  Future<void> refreshTab(int tabIndex) async {
    final state = tabStates[tabIndex];
    if (state.isRefreshing.value) return;
    state.isRefreshing.value = true;
    state.page = 0;
    state.hasMore.value = true;
    try {
      await _load(tabIndex, reset: true);
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
    final batch = await DealInvoiceMockRepository.fetch(
      tab: tab,
      page: state.page,
    );

    if (reset) {
      state.items.assignAll(batch);
    } else {
      state.items.addAll(batch);
    }

    if (batch.isEmpty) {
      state.hasMore.value = false;
    } else if (state.page >= DealInvoiceMockRepository.maxPages - 1) {
      state.hasMore.value = false;
    } else {
      state.hasMore.value = true;
    }
  }

  void onUploadTap() {
    Get.toNamed(
      RoutePath.dealInvoiceUpload,
      arguments: const DealInvoiceUploadArgs(
        scene: DealInvoiceUploadScene.create,
      ),
    );
  }

  void onItemTap(DealInvoiceItem item) {
    Get.toNamed(
      RoutePath.dealInvoiceUpload,
      arguments: DealInvoiceUploadArgs(
        scene: DealInvoiceUploadScene.detail,
        item: item,
      ),
    );
  }

  void onProcessTap(DealInvoiceItem item) {
    Get.toNamed(
      RoutePath.dealInvoiceUpload,
      arguments: DealInvoiceUploadArgs(
        scene: DealInvoiceUploadScene.reupload,
        item: item,
      ),
    );
  }
}
