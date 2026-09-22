import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_video/short_video/controller/short_video_controller.dart';
import 'package:module_video/short_video/mapper/short_video_player_mapper.dart';
import 'package:module_video/short_video/model/short_video_models.dart';
import 'package:module_video/short_video/model/short_video_play_args.dart';
import 'package:module_video/short_video/widgets/short_video_empty_state.dart';
import 'package:module_video/short_video/widgets/short_video_item_tile.dart';
import 'package:module_video/short_video/widgets/short_video_profile_card.dart';
import 'package:module_video/short_video/widgets/short_video_publish_tile.dart';

class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  late final ShortVideoController _c;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<ShortVideoController>()
        ? Get.find<ShortVideoController>()
        : Get.put(ShortVideoController());
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      _c.loadMore();
    }
  }

  void _toast(String message) => UiKitInitializer.toast(message);

  void _openHelp() => Get.toNamed(RoutePath.shortVideoHelp);

  void _playVideo(ShortVideoItemModel item) {
    if (item.status == ShortVideoStatus.uploading) {
      _toast('视频上传中，请稍后再试');
      return;
    }
    if (item.videoUrl == null || item.videoUrl!.isEmpty) {
      _toast('暂无可播放地址');
      return;
    }

    final index =
        ShortVideoPlayerMapper.indexForModelId(_c.items, item.id ?? '');
    Get.toNamed(
      RoutePath.shortVideoPlay,
      arguments: ShortVideoPlayArgs(
        initialIndex: index,
        items: List<ShortVideoItemModel>.from(_c.items),
      ),
    );
  }

  Future<void> _confirmDelete(ShortVideoItemModel item) async {
    final id = item.id;
    if (id == null || id.isEmpty) return;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除小视频'),
        content: Text('确定删除「${item.title ?? ''}」？'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) {
      await _c.deleteVideo(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      navBar: const AppNavBar(
        title: '小视频',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: Obx(() {
          // 订阅 UserService，头像/昵称与「我的」同步刷新
          Get.find<UserService>().currentUser.value;
          final profile = _c.displayProfile;
          final loading = _c.loading.value;
          final grid = _c.gridItems;
          final empty = !loading && _c.items.isEmpty;
          final loadingMore = _c.loadingMore.value;
          final hasMore = _c.hasMore.value;

          return RefreshIndicator(
            onRefresh: _c.refreshAll,
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFDCEEF9), Color(0xFFF5F5F5)],
                      ),
                    ),
                    child: ShortVideoProfileCard(
                      profile: profile,
                    ),
                  ),
                ),
                if (loading && _c.items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (empty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ShortVideoEmptyState(
                      onShootTap: _c.startPublishFlow,
                      onHelpTap: _openHelp,
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(onHelpTap: _openHelp),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childCount: grid.length,
                      itemBuilder: (context, index) {
                        final item = grid[index];
                        if (item.isPublish) {
                          return ShortVideoPublishTile(
                            aspectRatio: item.aspectRatio,
                            onTap: _c.startPublishFlow,
                          );
                        }
                        return ShortVideoItemTile(
                          item: item,
                          onTap: () => _playVideo(item),
                          onLongPress: () => _confirmDelete(item),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ListFooter(
                      loadingMore: loadingMore,
                      hasMore: hasMore,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onHelpTap});

  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Row(
        children: [
          Text(
            '我发布的小视频',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171717),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onHelpTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(Icons.help_outline,
                size: 14.sp, color: const Color(0xFF0070F3)),
            label: Text(
              '如何拍摄小视频',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0070F3)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.loadingMore, required this.hasMore});

  final bool loadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: loadingMore
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '加载中...',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey.shade500),
                  ),
                ],
              )
            : Text(
                hasMore ? '上拉加载更多' : '没有更多了',
                style:
                    TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
              ),
      ),
    );
  }
}
