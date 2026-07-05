import 'package:get/get.dart';
import 'package:module_home/home/mock/hot_rank_detail_mock_data.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_route/route/route_path.dart';

class HotRankDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HotRankDetailController>(
      () => HotRankDetailController(seedBoard: Get.arguments as DubbingHomeHotRankBoard?),
      fenix: true,
    );
  }
}

class HotRankDetailController extends GetxController {
  HotRankDetailController({this.seedBoard});

  final DubbingHomeHotRankBoard? seedBoard;
  final state = Rxn<HotRankDetailState>();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    state.value = HotRankDetailMockData.build(seedBoard: seedBoard);
  }

  void selectCategory(HotRankCategory category) {
    final current = state.value;
    if (current == null) return;
    state.value = current.copyWith(
      selectedCategory: category,
      showAgeFilterMenu: false,
    );
  }

  void toggleAgeFilterMenu() {
    final current = state.value;
    if (current == null) return;
    state.value = current.copyWith(showAgeFilterMenu: !current.showAgeFilterMenu);
  }

  void closeAgeFilterMenu() {
    final current = state.value;
    if (current == null || !current.showAgeFilterMenu) return;
    state.value = current.copyWith(showAgeFilterMenu: false);
  }

  void selectAgeFilter(HotRankAgeFilter filter) {
    final current = state.value;
    if (current == null) return;
    state.value = current.copyWith(
      selectedAgeFilter: filter,
      showAgeFilterMenu: false,
    );
  }

  void onItemTap(HotRankDetailItem item) {
    Get.toNamed<void>(
      RoutePath.dubbingVideoDetail,
      arguments: {'id': item.id},
    );
  }
}
