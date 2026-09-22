import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/controller/short_video_controller.dart';
import 'package:module_video/short_video/mapper/short_video_player_mapper.dart';
import 'package:module_video/short_video/model/short_video_models.dart';
import 'package:module_video/short_video/model/short_video_play_args.dart';

class ShortVideoPlayPage extends StatefulWidget {
  const ShortVideoPlayPage({
    super.key,
    this.initialIndex = 0,
    this.items = const [],
  });

  final int initialIndex;
  final List<ShortVideoItemModel> items;

  static ShortVideoPlayArgs resolveArgs() {
    final args = Get.arguments;
    if (args is ShortVideoPlayArgs) return args;
    if (args is int) return ShortVideoPlayArgs(initialIndex: args);
    return const ShortVideoPlayArgs();
  }

  @override
  State<ShortVideoPlayPage> createState() => _ShortVideoPlayPageState();
}

class _ShortVideoPlayPageState extends State<ShortVideoPlayPage> {
  late final List<ShortVideoItemModel> _source;
  late final List<ShortVideoItem> _playerItems;
  late final int _startIndex;
  final _reported = <String>{};

  @override
  void initState() {
    super.initState();
    final args = ShortVideoPlayPage.resolveArgs();
    _source = args.items.isNotEmpty ? args.items : widget.items;
    _playerItems = ShortVideoPlayerMapper.toPlayerItems(_source);
    final raw = args.items.isNotEmpty ? args.initialIndex : widget.initialIndex;
    _startIndex = _playerItems.isEmpty
        ? 0
        : raw.clamp(0, _playerItems.length - 1);
    if (_playerItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reportView(_playerItems[_startIndex].id);
      });
    }
  }

  void _reportView(String id) {
    if (id.isEmpty || _reported.contains(id)) return;
    _reported.add(id);
    if (Get.isRegistered<ShortVideoController>()) {
      Get.find<ShortVideoController>().reportView(id);
    }
  }

  void _onPlayback(PlaybackEvent event) {
    if (event.type == PlaybackEventType.play) {
      _reportView(event.itemId);
    }
    if (kDebugMode) {
      debugPrint(
        '[ShortVideoPlay] ${event.type.name} id=${event.itemId} '
        'index=${event.index} pos=${event.position}',
      );
    }
  }

  Future<void> _onLike(int index) async {
    if (index < 0 || index >= _playerItems.length) return;
    final id = _playerItems[index].id;
    if (id.isEmpty) return;
    ShortVideoItemModel? src;
    for (final e in _source) {
      if (e.id == id) {
        src = e;
        break;
      }
    }
    final liked = !(src?.isLiked ?? false);
    if (Get.isRegistered<ShortVideoController>()) {
      await Get.find<ShortVideoController>().toggleLike(id, liked);
      UiKitInitializer.toast(liked ? '已点赞' : '已取消赞');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_playerItems.isEmpty) {
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

    return VideoPlaybackImmersiveScope(
      child: AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ShortVideoPlayerKit.single(
              items: _playerItems,
              initialIndex: _startIndex,
              overlayBuilder: _buildOverlay,
              onDoubleTapLike: _onLike,
              onPlaybackEvent: _onPlayback,
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
}

Widget shortVideoPlayPageBuilder(BuildContext context) {
  final args = ShortVideoPlayPage.resolveArgs();
  return ShortVideoPlayPage(
    initialIndex: args.initialIndex,
    items: args.items,
  );
}
