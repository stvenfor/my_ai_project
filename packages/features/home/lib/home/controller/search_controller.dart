import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/mock/search_mock_data.dart';
import 'package:module_home/home/model/search_page_model.dart';

class HomeSearchController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  late final TextEditingController keywordController;

  final searchHistory = <String>[].obs;
  final searchDiscovery = <String>[].obs;
  final filterTags = <String>[].obs;
  final rankLists = <RxList<SearchRankItem>>[];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: SearchRankTab.values.length,
      vsync: this,
    );
    keywordController = TextEditingController(text: SearchMockData.defaultKeyword);
    searchHistory.assignAll(SearchMockData.searchHistory);
    searchDiscovery.assignAll(SearchMockData.searchDiscovery);
    filterTags.assignAll(SearchMockData.filterTags);
    rankLists.addAll(
      SearchRankTab.values.map(
        (tab) => SearchMockData.rankListForTab(tab).obs,
      ),
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    keywordController.dispose();
    super.onClose();
  }

  void onBack() => Get.back<void>();

  void onCancel() => Get.back<void>();

  void onTagTap(String keyword) {
    keywordController.text = keyword;
    keywordController.selection = TextSelection.collapsed(
      offset: keyword.length,
    );
  }

  void clearHistory() {
    searchHistory.clear();
  }

  void refreshDiscovery() {
    final items = List<String>.from(searchDiscovery);
    items.shuffle();
    searchDiscovery.assignAll(items);
  }

  void onVoiceTap() {
    UiKitInitializer.toast('语音搜索开发中');
  }

  void onRankItemTap(SearchRankItem item) {
    UiKitInitializer.toast('打开：${item.title}');
  }
}

class HomeSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeSearchController.new);
  }
}
