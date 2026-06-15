import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';
import 'package:module_settings/mine/model/level_card_model.dart';
import 'package:module_settings/mine/repository/mine_repository.dart';

enum MineLoadState { loading, success, error }

class MineHttpTestViewModel extends BaseViewModel {
  MineHttpTestViewModel({MineRepository? repository})
      : _repository = repository ?? MineRepository();

  final MineRepository _repository;
  final args = MineHttpTestArgs.empty();
  final loadState = MineLoadState.loading.obs;
  final indexModel = Rxn<HarmonyIndexModel>();
  final loadedAt = Rxn<DateTime>();

  @override
  void onReady() {
    super.onReady();
    updateArgs(Get.arguments);
  }

  void updateArgs(Object? arguments) {
    args.updateFromRoute(arguments);
    loadData();
  }

  Future<void> loadData() async {
    loadState.value = MineLoadState.loading;
    errorMessage.value = null;
    try {
      indexModel.value = await _repository.loadHarmonyIndex();
      loadState.value = MineLoadState.success;
      loadedAt.value = DateTime.now();
    } catch (error) {
      loadState.value = MineLoadState.error;
      errorMessage.value = error.toString();
    }
  }

  List<HarmonySectionModel> get visibleSections {
    final model = indexModel.value;
    if (model == null) return const [];
    final section = switch (args.level) {
      1 => model.links,
      2 => model.openSources,
      3 => model.tools,
      _ => null,
    };
    if (section != null) return [section];
    return model.allSections;
  }
}
