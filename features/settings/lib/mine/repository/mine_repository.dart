import 'package:module_auth/api/user_profile_api.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_settings/mine/api/mine_api.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';
import 'package:module_settings/mine/model/mine_stat_model.dart';

class MineRepository {
  MineRepository({
    MineApi? api,
    UserProfileApi? profileApi,
  })  : _api = api ?? MineApi(),
        _profileApi = profileApi ?? UserProfileApi();

  final MineApi _api;
  final UserProfileApi _profileApi;

  Future<HarmonyIndexModel> loadHarmonyIndex() => _api.fetchHarmonyIndex();

  Future<UserStoreStats> loadStoreStats({required String storeId}) async {
    final profile = await _profileApi.fetchMe(storeId: storeId);
    return profile.stats;
  }

  Future<UserStoreListResult> listMyStores() => _profileApi.listMyStores();

  Future<UserStoreStats> switchStore({required int storeId}) =>
      _profileApi.switchStore(storeId);

  static List<MineStatModel> statsToMineModels(UserStoreStats stats) {
    return [
      MineStatModel(value: '${stats.daysJoined}', label: '加入天数'),
      MineStatModel(value: '${stats.employeeCount}', label: '员工数'),
      MineStatModel(value: '${stats.storeDays}', label: '店铺天数'),
      MineStatModel(value: '${stats.totalCustomers}', label: '累计客户'),
    ];
  }
}
