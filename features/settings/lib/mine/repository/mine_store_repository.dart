import 'package:module_auth/store/current_store_service.dart';
import 'package:module_settings/mine/model/mine_store_data.dart';
import 'package:module_utils/module_utils.dart';

class MineStoreRepository {
  MineStoreRepository._();

  static String loadSelectedStoreId() {
    final stored = SpUtils.getString(CurrentStoreService.selectedStoreIdKey);
    if (stored == null || stored.isEmpty) {
      return MineStoreData.defaultStoreId;
    }
    return stored;
  }

  static Future<void> saveSelectedStoreId(String id) async {
    await SpUtils.setString(CurrentStoreService.selectedStoreIdKey, id);
  }

  static String resolveStoreName(String id) => MineStoreData.resolveStoreName(id);
}
