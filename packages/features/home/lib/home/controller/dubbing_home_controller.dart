import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/mock/dubbing_home_mock_data.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_route/route/route_path.dart';

class DubbingHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DubbingHomeController>(DubbingHomeController.new, fenix: true);
  }
}

class DubbingHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final feed = Rxn<DubbingHomeData>();
  final selectedCategory = DubbingHomeCategory.dubbing.obs;
  final bannerIndex = 0.obs;
  final hotRankSectionKey = GlobalKey();

  late final TabController categoryTabController;

  @override
  void onInit() {
    super.onInit();
    categoryTabController = TabController(
      length: DubbingHomeCategory.values.length,
      vsync: this,
      initialIndex: DubbingHomeCategory.dubbing.index,
    );
    categoryTabController.addListener(_onCategoryTabChanged);
    _loadFeed();
  }

  void _onCategoryTabChanged() {
    if (categoryTabController.indexIsChanging) return;
    selectedCategory.value = DubbingHomeCategory.values[categoryTabController.index];
  }

  Future<void> _loadFeed() async {
    feed.value = DubbingHomeMockData.build();
  }

  Future<void> refreshFeed() async {
    await _loadFeed();
  }

  void onBannerChanged(int index) {
    bannerIndex.value = index;
  }

  void onCategorySelected(DubbingHomeCategory category) {
    selectedCategory.value = category;
    categoryTabController.animateTo(category.index);
  }

  void onFeatureTap(DubbingHomeFeatureItem item) {
    switch (item.action) {
      case DubbingHomeFeatureAction.scrollToHotRank:
        _scrollToHotRank();
      case DubbingHomeFeatureAction.openAllServices:
        Get.toNamed<void>(RoutePath.homeAllServices);
      case null:
        break;
    }
  }

  void _scrollToHotRank() {
    final context = hotRankSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void onMediaTap(DubbingHomeMediaItem item) {
    Get.toNamed<void>(
      RoutePath.dubbingVideoDetail,
      arguments: {'id': item.id},
    );
  }

  void onAlbumTap(DubbingHomeAlbumItem item) {
    Get.toNamed<void>(
      RoutePath.dubbingVideoDetail,
      arguments: {'id': item.id},
    );
  }

  void onViewAllHotRank(DubbingHomeHotRankBoard board) {
    Get.toNamed<void>(
      RoutePath.homeHotRankDetail,
      arguments: board,
    );
  }

  void onHotRankItemTap(DubbingHomeHotRankItem item) {
    Get.toNamed<void>(
      RoutePath.dubbingVideoDetail,
      arguments: {'id': item.id},
    );
  }

  void openSearch() {
    Get.toNamed<void>(RoutePath.homeSearch);
  }

  @override
  void onClose() {
    categoryTabController.removeListener(_onCategoryTabChanged);
    categoryTabController.dispose();
    super.onClose();
  }
}
