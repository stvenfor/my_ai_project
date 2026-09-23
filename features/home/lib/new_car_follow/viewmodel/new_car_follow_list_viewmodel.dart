import 'package:get/get.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';

class NewCarFollowListViewModel extends GetxController {
  NewCarFollowListViewModel({NewCarFollowApi? api}) : _api = api ?? NewCarFollowApi();

  final NewCarFollowApi _api;

  final summary = Rxn<NewCarFollowSummary>();
  final tabIndex = 0.obs;
  final items = <NewCarFollowFile>[].obs;
  final loading = false.obs;
  final error = ''.obs;
  var _page = 1;
  var hasMore = true;

  NewCarFollowTab get tab => NewCarFollowTab.values[tabIndex.value];

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    loading.value = true;
    error.value = '';
    try {
      summary.value = await _api.fetchSummary();
      _page = 1;
      final res = await _api.fetchList(tab: tab, page: _page);
      items.assignAll(res.list);
      hasMore = res.hasMore;
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> switchTab(int index) async {
    if (index == tabIndex.value) return;
    tabIndex.value = index;
    await refreshAll();
  }

  Future<void> loadMore() async {
    if (!hasMore || loading.value) return;
    loading.value = true;
    try {
      final next = _page + 1;
      final res = await _api.fetchList(tab: tab, page: next);
      _page = next;
      items.addAll(res.list);
      hasMore = res.hasMore;
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }
}
