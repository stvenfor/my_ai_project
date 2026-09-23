import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_api.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_auth/store/store_option.dart';
import 'package:module_utils/module_utils.dart';

/// 当前选中经销商：首页「公司数据」与「我的」共用，切换后两端同步。
class CurrentStoreService extends GetxService {
  CurrentStoreService({UserProfileApi? profileApi})
      : _api = profileApi ?? UserProfileApi();

  static const selectedStoreIdKey = 'mine_selected_store_id';

  final UserProfileApi _api;

  final storeId = ''.obs;
  final storeName = ''.obs;
  final stores = <StoreOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    final stored = SpUtils.getString(selectedStoreIdKey);
    if (stored != null && stored.isNotEmpty) {
      storeId.value = stored;
    }
  }

  /// 拉取可切换列表，并尽量对齐服务端 current_store_id。
  Future<void> refreshStores() async {
    final result = await _api.listMyStores();
    stores.assignAll([
      for (final item in result.list)
        if (item.storeId > 0)
          StoreOption(
            id: '${item.storeId}',
            name: item.storeName.isNotEmpty
                ? item.storeName
                : '店铺 ${item.storeId}',
          ),
    ]);
    if (result.currentStoreId > 0) {
      await _applySelection(
        id: '${result.currentStoreId}',
        name: _nameOf('${result.currentStoreId}'),
      );
    } else if (stores.isNotEmpty &&
        !stores.any((s) => s.id == storeId.value)) {
      await _applySelection(id: stores.first.id, name: stores.first.name);
    } else if (storeId.value.isNotEmpty && storeName.value.isEmpty) {
      storeName.value = _nameOf(storeId.value);
    }
  }

  /// 切换店铺；成功后更新本服务状态并持久化。
  Future<UserStoreStats> switchTo(String id) async {
    final storeIdInt = int.tryParse(id);
    if (storeIdInt == null || storeIdInt <= 0) {
      throw ArgumentError.value(id, 'id', 'invalid store id');
    }
    final stats = await _api.switchStore(storeIdInt);
    final resolvedId =
        stats.storeId > 0 ? '${stats.storeId}' : id;
    final resolvedName = stats.storeName.isNotEmpty
        ? stats.storeName
        : _nameOf(resolvedId);
    await _applySelection(id: resolvedId, name: resolvedName);
    for (var i = 0; i < stores.length; i++) {
      if (stores[i].id == resolvedId && resolvedName.isNotEmpty) {
        stores[i] = StoreOption(id: resolvedId, name: resolvedName);
        break;
      }
    }
    return stats;
  }

  Future<void> clear() async {
    storeId.value = '';
    storeName.value = '';
    stores.clear();
  }

  String _nameOf(String id) {
    for (final store in stores) {
      if (store.id == id) return store.name;
    }
    return storeName.value.isNotEmpty ? storeName.value : id;
  }

  Future<void> _applySelection({
    required String id,
    required String name,
  }) async {
    storeId.value = id;
    if (name.isNotEmpty) storeName.value = name;
    await SpUtils.setString(selectedStoreIdKey, id);
  }
}
