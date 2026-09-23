import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';

class NewCarFollowTabState {
  final items = <NewCarFollowFile>[].obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final loaded = false.obs;
  int page = 1;
}

class NewCarFollowListViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  NewCarFollowListViewModel({NewCarFollowApi? api})
      : _api = api ?? NewCarFollowApi();

  final NewCarFollowApi _api;
  late final TabController tabController;

  final summary = Rxn<NewCarFollowSummary>();
  final error = ''.obs;
  final tabStates = List.generate(
    NewCarFollowTab.values.length,
    (_) => NewCarFollowTabState(),
  );

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: NewCarFollowTab.values.length,
      vsync: this,
    );
    refreshAll();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> refreshAll() async {
    error.value = '';
    try {
      summary.value = await _api.fetchSummary();
    } catch (e) {
      error.value = '$e';
    }
    for (var i = 0; i < NewCarFollowTab.values.length; i++) {
      await refreshTab(i);
    }
  }

  Future<void> refreshTab(int index) async {
    final state = tabStates[index];
    state.isRefreshing.value = true;
    state.page = 1;
    try {
      final res = await _api.fetchList(
        tab: NewCarFollowTab.values[index],
        page: 1,
      );
      state.items.assignAll(res.list);
      state.hasMore.value = res.hasMore;
      state.loaded.value = true;
      error.value = '';
    } catch (e) {
      error.value = '$e';
    } finally {
      state.isRefreshing.value = false;
    }
  }

  Future<void> loadMore(int index) async {
    final state = tabStates[index];
    if (!state.hasMore.value ||
        state.isLoadingMore.value ||
        state.isRefreshing.value) {
      return;
    }
    state.isLoadingMore.value = true;
    try {
      final next = state.page + 1;
      final res = await _api.fetchList(
        tab: NewCarFollowTab.values[index],
        page: next,
      );
      state.page = next;
      state.items.addAll(res.list);
      state.hasMore.value = res.hasMore;
    } catch (e) {
      error.value = '$e';
    } finally {
      state.isLoadingMore.value = false;
    }
  }
}
