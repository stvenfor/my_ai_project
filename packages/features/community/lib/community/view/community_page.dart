import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/theme/community_theme.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_community/community/widgets/post_card_widget.dart';
import 'package:module_community/community/widgets/post_skeleton_widget.dart';
import 'package:module_route/route/route_path.dart';

class CommunityPage extends GetView<CommunityViewModel> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.mainTabRoot,
      backgroundColor: CommunityTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 840
              ? CommunityTheme.contentMaxWidth
              : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CommunityHeader(
                    onPublish: () => Get.toNamed(RoutePath.communityPublish),
                  ),
                  Expanded(child: _buildBody(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return const PostSkeletonWidget();
      }

      if (controller.errorMessage.value != null && controller.posts.isEmpty) {
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = controller.posts[index];
                    return GetBuilder<CommunityViewModel>(
                      id: post.id,
                      builder: (vm) {
                        final current = vm.postById(post.id) ?? post;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PostCardWidget(
                            key: ValueKey(post.id),
                            post: current,
                          ),
                        );
                      },
                    );
                  },
                  childCount: controller.posts.length,
                ),
              ),
            ),
            if (controller.isLoadingMore.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSafeInsets.bottom(context) + 16),
            ),
          ],
        ),
      );
    });
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader({required this.onPublish});

  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        AppSafeInsets.top(context) + 8,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('社区', style: CommunityTheme.largeTitle)),
              SizedBox(
                width: 44,
                height: 44,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onPublish,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CommunityTheme.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: CommunityTheme.surface,
                borderRadius: BorderRadius.circular(CommunityTheme.radiusMd),
                border: Border.all(color: CommunityTheme.separator, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: CommunityTheme.labelSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '搜索动态、话题、用户',
                    style: CommunityTheme.caption.copyWith(
                      color: CommunityTheme.labelTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _FilterTabs(),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatefulWidget {
  const _FilterTabs();

  @override
  State<_FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<_FilterTabs> {
  int _selected = 0;
  static const _tabs = ['最新', '热门', '关注'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final active = index == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _tabs[index],
                  style: CommunityTheme.headline.copyWith(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? CommunityTheme.labelPrimary
                        : CommunityTheme.labelSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 20 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: CommunityTheme.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
      color: CommunityTheme.accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.chat_bubble_2,
                  size: 56,
                  color: CommunityTheme.labelTertiary,
                ),
                const SizedBox(height: 12),
                Text('暂无动态', style: CommunityTheme.caption),
                const SizedBox(height: 8),
                Text(
                  '发布第一条动态，开始互动吧',
                  style: CommunityTheme.caption.copyWith(
                    color: CommunityTheme.labelTertiary,
                  ),
                ),
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
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48,
            color: CommunityTheme.labelTertiary,
          ),
          const SizedBox(height: 12),
          Text('加载失败', style: CommunityTheme.headline),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: CommunityTheme.caption,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: onRetry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
