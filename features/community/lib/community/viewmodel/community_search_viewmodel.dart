import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/community_search_models.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunitySearchViewModel extends GetxController {
  CommunitySearchViewModel({PostRepository? repository})
      : _repo = repository ?? Get.find<PostRepository>();

  static const historyKey = 'community_search_history';
  static const maxHistory = 10;
  static const allPreviewSize = 5;
  static const pageSize = 10;

  final PostRepository _repo;
  final queryController = TextEditingController();

  final tabIndex = 0.obs;
  final queryText = ''.obs;
  final history = <String>[].obs;
  final hotTopics = <TopicModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final allResult = Rxn<CommunitySearchAllResult>();
  final posts = <PostModel>[].obs;
  final topics = <TopicModel>[].obs;
  final users = <CommunityUserHit>[].obs;

  Timer? _debounce;
  int _page = 0;
  String _lastQuery = '';

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
    _loadHotTopics();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    queryController.dispose();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    history.assignAll(prefs.getStringList(historyKey) ?? const []);
  }

  Future<void> _loadHotTopics() async {
    try {
      final list = await _repo.fetchTopics(pageSize: 10);
      hotTopics.assignAll(list.where((t) => !t.isAskEveryone));
    } catch (_) {
      // 热门话题失败不阻断搜索页
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
    history.clear();
  }

  Future<void> addHistory(String q) async {
    final text = q.trim();
    if (text.isEmpty) return;
    final next = [text, ...history.where((e) => e != text)].take(maxHistory).toList();
    history.assignAll(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(historyKey, next);
  }

  void onQueryChanged(String value) {
    queryText.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      search(immediate: true);
    });
  }

  void onQuerySubmitted(String value) {
    queryText.value = value;
    _debounce?.cancel();
    search(immediate: true);
  }

  void selectTab(int index) {
    if (tabIndex.value == index) return;
    tabIndex.value = index;
    if (queryController.text.trim().isNotEmpty) {
      search(immediate: true);
    }
  }

  void applyKeyword(String keyword) {
    queryController.text = keyword;
    queryController.selection = TextSelection.collapsed(offset: keyword.length);
    queryText.value = keyword;
    search(immediate: true);
  }

  Future<void> search({bool immediate = false, bool loadMore = false}) async {
    final q = queryController.text.trim();
    if (!loadMore) {
      _page = 0;
      hasMore.value = true;
      if (q.isEmpty) {
        allResult.value = null;
        posts.clear();
        topics.clear();
        users.clear();
        return;
      }
    }

    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value || q.isEmpty) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      if (tabIndex.value == 0) {
        final result = await _repo.searchAll(
          q: q,
          page: _page,
          pageSize: allPreviewSize,
        );
        if (loadMore) {
          // 全部 Tab 不分页，仅首屏预览
        } else {
          allResult.value = result;
          posts.assignAll(result.posts.list);
          topics.assignAll(result.topics.list);
          users.assignAll(result.users.list);
          hasMore.value = false;
        }
      } else if (tabIndex.value == 1) {
        final result = await _repo.searchPosts(
          q: q,
          page: _page,
          pageSize: pageSize,
        );
        if (loadMore) {
          posts.addAll(result.list);
        } else {
          posts.assignAll(result.list);
        }
        hasMore.value = result.hasMore;
      } else if (tabIndex.value == 2) {
        final result = await _repo.searchTopicsPage(
          q: q,
          page: _page,
          pageSize: pageSize,
        );
        if (loadMore) {
          topics.addAll(result.list);
        } else {
          topics.assignAll(result.list);
        }
        hasMore.value = result.hasMore;
      } else {
        final result = await _repo.searchUsers(
          q: q,
          page: _page,
          pageSize: pageSize,
        );
        if (loadMore) {
          users.addAll(result.list);
        } else {
          users.assignAll(result.list);
        }
        hasMore.value = result.hasMore;
      }

      if (!loadMore && q.isNotEmpty && q != _lastQuery) {
        await addHistory(q);
      }
      _lastQuery = q;
      if (hasMore.value) _page++;
    } catch (e) {
      UiKitInitializer.toastError('搜索失败');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> toggleFollow(CommunityUserHit user) async {
    try {
      if (user.isFollowed) {
        await _repo.unfollowUser(user.userId);
      } else {
        await _repo.followUser(user.userId);
      }
      final updated = user.copyWith(isFollowed: !user.isFollowed);
      _replaceUser(updated);
      UiKitInitializer.toast(user.isFollowed ? '已取消关注' : '已关注');
    } catch (_) {
      UiKitInitializer.toastError('操作失败');
    }
  }

  void _replaceUser(CommunityUserHit updated) {
    final index = users.indexWhere((u) => u.userId == updated.userId);
    if (index >= 0) users[index] = updated;
    final all = allResult.value;
    if (all == null) return;
    final userList = all.users.list
        .map((u) => u.userId == updated.userId ? updated : u)
        .toList();
    allResult.value = CommunitySearchAllResult(
      q: all.q,
      posts: all.posts,
      topics: all.topics,
      users: ListData(list: userList, pagination: all.users.pagination),
    );
  }

  void onTopicTap(TopicModel topic) {
    addHistory(topic.name);
    UiKitInitializer.toast(topic.displayName);
  }
}

class CommunitySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunitySearchViewModel>(() => CommunitySearchViewModel());
  }
}
