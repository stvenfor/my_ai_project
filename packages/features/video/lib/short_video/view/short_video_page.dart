import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/mapper/short_video_player_mapper.dart';
import 'package:module_video/short_video/mock/short_video_mock_data.dart';
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
  bool _showEmptyState = false;

  static const _defaultAvatar =
      'https://picsum.photos/seed/short_video_profile/200/200';

  ShortVideoProfileModel _buildProfile() {
    final user = Get.find<UserService>().currentUser.value;
    final stats =
        _showEmptyState ? ShortVideoStatsModel.empty : ShortVideoStatsModel.demo;

    return ShortVideoProfileModel(
      displayName: user?.name.isNotEmpty == true ? user!.name : '东东枪',
      avatarUrl: user?.avatar.isNotEmpty == true ? user!.avatar : _defaultAvatar,
      roleBadge: '销售经理',
      storeName: '[4S] 北京沃德龙鼎吉利',
      stats: stats,
    );
  }

  void _toast(String message) => UiKitInitializer.toast(message);

  void _playVideo(ShortVideoItemModel item) {
    if (item.status == ShortVideoStatus.reviewing) {
      _toast('视频审核中，暂不可播放');
      return;
    }
    if (item.status == ShortVideoStatus.uploading) {
      _toast('视频上传中，请稍后再试');
      return;
    }

    final index = ShortVideoPlayerMapper.indexForModelId(
      ShortVideoMockData.listItems,
      item.id ?? '',
    );
    Get.toNamed(
      RoutePath.shortVideoPlay,
      arguments: ShortVideoPlayArgs(initialIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _buildProfile();

    return AppPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      navBar: AppNavBar(
        title: '小视频',
        showBackButton: true,
        backgroundColor: Colors.white,
        actions: kDebugMode
            ? [
                IconButton(
                  tooltip: _showEmptyState ? '切换列表态' : '切换空态',
                  icon: Icon(
                    _showEmptyState ? Icons.grid_view_rounded : Icons.inbox_outlined,
                  ),
                  onPressed: () {
                    setState(() => _showEmptyState = !_showEmptyState);
                  },
                ),
              ]
            : null,
      ),
      body: ColoredBox(
        color: const Color(0xFFF5F6F8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFDCEEF9), Color(0xFFF5F6F8)],
                  ),
                ),
                child: ShortVideoProfileCard(profile: profile),
              ),
            ),
            if (_showEmptyState)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ShortVideoEmptyState(
                  onShootTap: () => _toast('拍摄小视频（开发中）'),
                  onHelpTap: () => _toast('如何拍摄小视频（开发中）'),
                ),
              )
            else ...[
              SliverToBoxAdapter(child: _SectionHeader(onHelpTap: () => _toast('如何拍摄小视频（开发中）'))),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                  childCount: ShortVideoMockData.listItems.length,
                  itemBuilder: (context, index) {
                    final item = ShortVideoMockData.listItems[index];
                    if (item.isPublish) {
                      return ShortVideoPublishTile(
                        aspectRatio: item.aspectRatio,
                        onTap: () => _toast('发布小视频（开发中）'),
                      );
                    }
                    return ShortVideoItemTile(
                      item: item,
                      onTap: () => _playVideo(item),
                      onLongPress: () => _toast('长按删除（开发中）'),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _LoadingFooter()),
            ],
          ],
        ),
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
              color: const Color(0xFF1A1A1A),
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
            icon: Icon(Icons.help_outline, size: 14.sp, color: const Color(0xFF1890FF)),
            label: Text(
              '如何拍摄小视频',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1890FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1890FF),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '加载中...',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
