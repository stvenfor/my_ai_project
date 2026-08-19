import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/repository/mock_post_repository.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_community/community/widgets/comment_bottom_sheet.dart';
import 'package:module_common_ui/module_common_ui.dart';

class CommunityViewModel extends GetxController {
  CommunityViewModel({PostRepository? repository})
      : _repository = repository ?? MockPostRepository.instance;

  final PostRepository _repository;

  final posts = <PostModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final currentPage = 0.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  /// 展开状态（UI 态，不进 PostModel）
  final expandedPostIds = <String>{}.obs;

  static const pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  PostModel? postById(String id) {
    try {
      return posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isExpanded(String postId) => expandedPostIds.contains(postId);

  void toggleExpanded(String postId) {
    if (expandedPostIds.contains(postId)) {
      expandedPostIds.remove(postId);
    } else {
      expandedPostIds.add(postId);
    }
    update([postId]);
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    errorMessage.value = null;
    currentPage.value = 0;
    try {
      final list = await _repository.fetchPosts(page: 0, pageSize: pageSize);
      posts.assignAll(list);
      hasMore.value = list.length >= pageSize;
      currentPage.value = list.isEmpty ? 0 : 1;
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      final list = await _repository.fetchPosts(page: 0, pageSize: pageSize);
      posts.assignAll(list);
      hasMore.value = list.length >= pageSize;
      currentPage.value = list.isEmpty ? 0 : 1;
      expandedPostIds.clear();
    } catch (error) {
      errorMessage.value = error.toString();
      UiKitInitializer.toastError('刷新失败');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final page = currentPage.value;
      final list = await _repository.fetchPosts(page: page, pageSize: pageSize);
      if (list.isEmpty) {
        hasMore.value = false;
      } else {
        posts.addAll(list);
        currentPage.value = page + 1;
        hasMore.value = list.length >= pageSize;
      }
    } catch (error) {
      UiKitInitializer.toastError('加载更多失败');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final post = postById(postId);
    if (post == null) return;
    final target = !post.isLiked;
    try {
      final updated = await _repository.toggleLike(postId, target);
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) posts[index] = updated;
      update([postId]);
    } catch (_) {
      UiKitInitializer.toastError('操作失败');
    }
  }

  Future<List<CommentModel>> loadComments(String postId) {
    return _repository.fetchComments(postId);
  }

  Future<void> sendComment({
    required String postId,
    required String content,
    String? replyToNickname,
  }) async {
    if (content.trim().isEmpty) return;
    try {
      await _repository.addComment(
        postId: postId,
        content: content.trim(),
        replyToNickname: replyToNickname,
      );
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        final comments = await _repository.fetchComments(postId);
        final post = posts[index];
        posts[index] = post.copyWith(
          commentCount: comments.length,
          previewComments: comments.take(2).toList(),
        );
      }
      update([postId]);
      UiKitInitializer.toast('评论成功');
    } catch (_) {
      UiKitInitializer.toastError('评论失败');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      posts.removeWhere((p) => p.id == postId);
      expandedPostIds.remove(postId);
      UiKitInitializer.toast('已删除');
    } catch (_) {
      UiKitInitializer.toastError('删除失败');
    }
  }

  void copyPostContent(PostModel post) {
    Clipboard.setData(ClipboardData(text: post.content));
    UiKitInitializer.toast('已复制');
  }

  void showCommentSheet(PostModel post) {
    CommentBottomSheet.show(post);
  }

  static String formatPublishTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays == 1) return '昨天';
    return '${time.month}月${time.day}日';
  }
}

class CommunityBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CommunityViewModel>(
        CommunityViewModel.new,
        fenix: true,
      );
}
