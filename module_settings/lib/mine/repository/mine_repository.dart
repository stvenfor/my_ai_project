import 'package:module_settings/mine/api/mine_api.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';

class MineRepository {
  MineRepository({MineApi? api}) : _api = api ?? MineApi();

  final MineApi _api;

  Future<HarmonyIndexModel> loadHarmonyIndex() => _api.fetchHarmonyIndex();
}
