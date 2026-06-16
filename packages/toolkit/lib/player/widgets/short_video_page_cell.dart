import 'package:flutter/material.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/player/widgets/danmaku_mock_layer.dart';
import 'package:module_utils/player/widgets/short_video_gesture_handler.dart';
import 'package:module_utils/utils/app_video_player.dart';
import 'package:module_utils/utils/cache_image_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 单条短视频页面（画面 + 手势 + 弹幕 + 进度）。
class ShortVideoPageCell extends StatefulWidget {
  const ShortVideoPageCell({
    super.key,
    required this.index,
    required this.item,
    required this.isActive,
    required this.controller,
    required this.initialized,
    this.danmakuItems,
    this.overlayBuilder,
    this.onDoubleTapLike,
    this.onPlaybackEvent,
    this.onRequestFullscreen,
    this.onTogglePlayPause,
  });

  final int index;
  final ShortVideoItem item;
  final bool isActive;
  final VideoPlayerController? controller;
  final bool initialized;
  final List<DanmakuMockItem>? danmakuItems;
  final ShortVideoOverlayBuilder? overlayBuilder;
  final VoidCallback? onDoubleTapLike;
  final ShortVideoPlaybackCallback? onPlaybackEvent;
  final VoidCallback? onRequestFullscreen;
  final Future<void> Function()? onTogglePlayPause;

  @override
  State<ShortVideoPageCell> createState() => _ShortVideoPageCellState();
}

class _ShortVideoPageCellState extends State<ShortVideoPageCell> {
  bool _showPauseIcon = false;
  bool _showLikeBurst = false;

  @override
  void didUpdateWidget(covariant ShortVideoPageCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WakelockPlus.enable();
    } else if (!widget.isActive && oldWidget.isActive) {
      WakelockPlus.disable();
    }
  }

  @override
  void dispose() {
    if (widget.isActive) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  void _flashPauseIcon() {
    setState(() => _showPauseIcon = true);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showPauseIcon = false);
    });
  }

  void _triggerLikeBurst() {
    setState(() => _showLikeBurst = true);
    widget.onDoubleTapLike?.call();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showLikeBurst = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final videoReady = widget.initialized && controller != null;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!videoReady)
            _Cover(item: widget.item)
          else
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: AppVideoPlayer.view(controller, fit: BoxFit.cover),
              ),
            ),
          if (videoReady)
            ShortVideoGestureHandler(
              controller: controller,
              enabled: widget.isActive,
              onSingleTap: () async {
                await widget.onTogglePlayPause?.call();
                _flashPauseIcon();
              },
              onDoubleTap: _triggerLikeBurst,
              onSeek: (position) {
                widget.onPlaybackEvent?.call(
                  PlaybackEvent(
                    type: PlaybackEventType.seek,
                    index: widget.index,
                    itemId: widget.item.id,
                    position: position,
                  ),
                );
              },
            ),
          DanmakuMockLayer(items: widget.danmakuItems ?? const []),
          if (_showPauseIcon && videoReady && !controller.value.isPlaying)
            Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 72,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          if (_showLikeBurst)
            const Center(
              child: Icon(Icons.favorite, color: Colors.redAccent, size: 96),
            ),
          if (widget.overlayBuilder != null)
            widget.overlayBuilder!(context, widget.index, widget.item),
          Positioned(
            right: 12,
            bottom: 100,
            child: IconButton(
              onPressed: widget.onRequestFullscreen,
              icon: const Icon(Icons.screen_rotation, color: Colors.white70),
              tooltip: '横屏全屏',
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.item});

  final ShortVideoItem item;

  @override
  Widget build(BuildContext context) {
    final cover = item.coverUrl;
    if (cover == null || cover.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    return CacheImageUtils.network(cover, fit: BoxFit.cover);
  }
}
