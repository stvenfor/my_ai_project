import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/mapper/short_video_player_mapper.dart';
import 'package:module_video/short_video/mock/short_video_mock_data.dart';
import 'package:module_video/short_video/model/short_video_play_args.dart';

class ShortVideoPlayPage extends StatelessWidget {
  const ShortVideoPlayPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  static int resolveInitialIndex() {
    final args = Get.arguments;
    if (args is ShortVideoPlayArgs) return args.initialIndex;
    if (args is int) return args;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = ShortVideoPlayerMapper.toPlayerItems(ShortVideoMockData.listItems);
    if (items.isEmpty) {
      return AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('暂无可播放视频', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: Get.back,
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    final index = initialIndex.clamp(0, items.length - 1);

    return VideoPlaybackImmersiveScope(
      child: AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ShortVideoPlayerKit.single(
              items: items,
              initialIndex: index,
              overlayBuilder: _buildOverlay,
              onDoubleTapLike: (i) => UiKitInitializer.toast('点赞（开发中）'),
              onPlaybackEvent: kDebugMode ? _logPlaybackEvent : null,
            ),
            Positioned(
              left: 4.w,
              top: AppSafeInsets.top(context) + 4.h,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOverlay(
    BuildContext context,
    int index,
    ShortVideoItem item,
  ) {
    final title = item.title;
    if (title == null || title.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 16.w,
      right: 72.w,
      bottom: 28.h,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 6),
          ],
        ),
      ),
    );
  }

  static void _logPlaybackEvent(PlaybackEvent event) {
    debugPrint('[ShortVideoPlay] ${event.type.name} #${event.index} ${event.itemId}');
  }
}

/// 路由工厂：从 [Get.arguments] 解析初始索引。
Widget shortVideoPlayPageBuilder(_) {
  return ShortVideoPlayPage(initialIndex: ShortVideoPlayPage.resolveInitialIndex());
}
