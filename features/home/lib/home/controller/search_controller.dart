import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/mock/search_mock_data.dart';
import 'package:module_home/home/model/search_page_model.dart';

class HomeSearchController extends GetxController {
  static const _rotateInterval = Duration(seconds: 2);

  late final TextEditingController keywordController;
  late final FocusNode searchFocusNode;

  final searchHistory = <String>[].obs;
  final searchDiscovery = <String>[].obs;
  final filterTags = <String>[].obs;
  final rankLists = <RxList<SearchRankItem>>[];
  final rotateIndex = 0.obs;
  final showRotatingOverlay = false.obs;

  Timer? _rotateTimer;
  bool _isUserEditing = false;

  @override
  void onInit() {
    super.onInit();
    keywordController = TextEditingController();
    searchFocusNode = FocusNode();
    searchFocusNode.addListener(_onFocusChanged);
    keywordController.addListener(_updateOverlayVisibility);
    searchHistory.assignAll(SearchMockData.searchHistory);
    searchDiscovery.assignAll(SearchMockData.searchDiscovery);
    filterTags.assignAll(SearchMockData.filterTags);
    rankLists.addAll(
      SearchRankTab.values.map(
        (tab) => SearchMockData.rankListForTab(tab).obs,
      ),
    );
    _updateOverlayVisibility();
    _startRotation();
  }

  String get currentRotatingKeyword {
    final items = searchHistory;
    if (items.isEmpty) return '';
    return items[rotateIndex.value % items.length];
  }

  String get currentSearchKeyword {
    final typed = keywordController.text.trim();
    if (typed.isNotEmpty) return typed;
    if (showRotatingOverlay.value) return currentRotatingKeyword;
    return '';
  }

  void _onFocusChanged() {
    if (searchFocusNode.hasFocus) {
      _isUserEditing = true;
      _pauseRotation();
      return;
    }
    if (keywordController.text.trim().isEmpty) {
      _isUserEditing = false;
      _startRotation();
    }
    _updateOverlayVisibility();
  }

  void _updateOverlayVisibility() {
    showRotatingOverlay.value = !_isUserEditing &&
        !searchFocusNode.hasFocus &&
        searchHistory.isNotEmpty &&
        keywordController.text.trim().isEmpty;
  }

  void _pauseRotation() {
    _rotateTimer?.cancel();
    _rotateTimer = null;
    _updateOverlayVisibility();
  }

  void _startRotation() {
    if (_isUserEditing || searchFocusNode.hasFocus || searchHistory.isEmpty) {
      _updateOverlayVisibility();
      return;
    }
    _rotateTimer?.cancel();
    rotateIndex.value = 0;
    _updateOverlayVisibility();
    _rotateTimer = Timer.periodic(_rotateInterval, (_) => _advanceRotation());
  }

  void _advanceRotation() {
    if (!showRotatingOverlay.value || searchHistory.isEmpty) return;
    rotateIndex.value = (rotateIndex.value + 1) % searchHistory.length;
  }

  @override
  void onClose() {
    _rotateTimer?.cancel();
    searchFocusNode.removeListener(_onFocusChanged);
    keywordController.removeListener(_updateOverlayVisibility);
    keywordController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void onBack() => Get.back<void>();

  void onCancel() => Get.back<void>();

  void clearKeyword() {
    _isUserEditing = true;
    _pauseRotation();
    keywordController.clear();
    _updateOverlayVisibility();
    searchFocusNode.requestFocus();
  }

  void submitCurrentKeyword() => onSearchSubmit();

  void onSearchSubmit([String? value]) {
    final text = value?.trim().isNotEmpty == true
        ? value!.trim()
        : currentSearchKeyword;
    if (text.isEmpty) return;
    _isUserEditing = true;
    _pauseRotation();
    keywordController.text = text;
    _addHistory(text);
    _updateOverlayVisibility();
    UiKitInitializer.toast('搜索：$text');
  }

  void onTagTap(String keywordText) {
    _isUserEditing = true;
    _pauseRotation();
    keywordController.text = keywordText;
    keywordController.selection = TextSelection.collapsed(
      offset: keywordText.length,
    );
    _addHistory(keywordText);
    _updateOverlayVisibility();
  }

  void _addHistory(String text) {
    searchHistory.remove(text);
    searchHistory.insert(0, text);
    if (searchHistory.length > 10) {
      searchHistory.removeRange(10, searchHistory.length);
    }
    rotateIndex.value = 0;
  }

  void clearHistory() {
    searchHistory.clear();
    rotateIndex.value = 0;
    if (!_isUserEditing && !searchFocusNode.hasFocus) {
      keywordController.clear();
      _startRotation();
    }
    _updateOverlayVisibility();
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
