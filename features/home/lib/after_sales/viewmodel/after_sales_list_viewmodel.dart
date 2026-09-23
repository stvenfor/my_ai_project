import 'package:get/get.dart';
import 'package:module_home/after_sales/api/after_sales_api.dart';
import 'package:module_home/after_sales/model/after_sales_models.dart';

class AfterSalesListViewModel extends GetxController {
  AfterSalesListViewModel({AfterSalesApi? api}) : _api = api ?? AfterSalesApi();

  final AfterSalesApi _api;

  final items = <AfterSalesRecord>[].obs;
  final appointments = <AfterSalesAppointment>[].obs;
  final canCreate = false.obs;
  final loading = false.obs;
  final error = ''.obs;
  final hasMore = true.obs;
  var _page = 1;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    loading.value = true;
    error.value = '';
    try {
      _page = 1;
      final res = await _api.fetchRecords(page: _page);
      items.assignAll(res.list);
      hasMore.value = res.hasMore;
      canCreate.value = res.canCreate;
      if (res.canCreate) {
        try {
          appointments.assignAll(await _api.fetchPendingAppointments());
        } catch (_) {
          appointments.clear();
        }
      } else {
        appointments.clear();
      }
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || loading.value) return;
    loading.value = true;
    try {
      final next = _page + 1;
      final res = await _api.fetchRecords(page: next);
      _page = next;
      items.addAll(res.list);
      hasMore.value = res.hasMore;
      canCreate.value = res.canCreate;
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }
}
