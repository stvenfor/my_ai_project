import 'package:module_settings/mine/model/mine_store_data.dart';
import 'package:module_utils/module_utils.dart';

class MineStoreRepository {
  MineStoreRepository._();

  static const _selectedStoreIdKey = 'mine_selected_store_id';

  static String loadSelectedStoreId() {
    final stored = SpUtils.getString(_selectedStoreIdKey);
    if (stored == null || stored.isEmpty) {
      return MineStoreData.defaultStoreId;
    }
    if (MineStoreData.findById(stored) == null) {
      return MineStoreData.defaultStoreId;
    }
    return stored;
  }

  static Future<void> saveSelectedStoreId(String id) async {
    await SpUtils.setString(_selectedStoreIdKey, id);
  }

  static String resolveStoreName(String id) => MineStoreData.resolveStoreName(id);
}
