import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_community/community/widgets/post_card_widget.dart';
import 'package:module_community/community/widgets/post_skeleton_widget.dart';
import 'package:module_route/route/route_path.dart';

class CommunityPage extends GetView<CommunityViewModel> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: AppNavBar(
        title: '社区',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Get.toNamed(RoutePath.communityPublish),
            tooltip: '发布',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const PostSkeletonWidget();
        }

        if (controller.errorMessage.value != null &&
            controller.posts.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.loadPosts,
          );
        }

        if (controller.posts.isEmpty) {
          return _EmptyState(onRefresh: controller.refreshPosts);
        }

        return AppRefreshView(
          onRefresh: controller.refreshPosts,
          onLoad: controller.loadMorePosts,
          enableLoad: controller.hasMore.value,
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = controller.posts[index];
                    return GetBuilder<CommunityViewModel>(
                      id: post.id,
                      builder: (vm) {
                        final current = vm.postById(post.id) ?? post;
                        return PostCardWidget(
                          key: ValueKey(post.id),
                          post: current,
                        );
                      },
                    );
                  },
                  childCount: controller.posts.length,
                ),
              ),
              if (controller.isLoadingMore.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('暂无动态', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('加载失败'),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('点击重试')),
        ],
      ),
    );
  }
}
