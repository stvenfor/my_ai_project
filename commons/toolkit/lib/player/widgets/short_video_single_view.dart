import 'package:flutter/material.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/player/widgets/short_video_feed_view.dart';

/// 单条/多条短视频播放页（内部复用 [ShortVideoFeedView]）。
class ShortVideoSingleView extends StatelessWidget {
  const ShortVideoSingleView({
    super.key,
    required this.items,
    required this.initialIndex,
    this.danmakuItems,
    this.overlayBuilder,
    this.onDoubleTapLike,
    this.onPlaybackEvent,
  });

  final List<ShortVideoItem> items;
  final int initialIndex;
  final List<DanmakuMockItem>? danmakuItems;
  final ShortVideoOverlayBuilder? overlayBuilder;
  final ShortVideoIndexCallback? onDoubleTapLike;
  final ShortVideoPlaybackCallback? onPlaybackEvent;

  @override
  Widget build(BuildContext context) {
    return ShortVideoFeedView(
      items: items,
      initialIndex: initialIndex,
      danmakuItems: danmakuItems,
      overlayBuilder: overlayBuilder,
      onDoubleTapLike: onDoubleTapLike,
      onPlaybackEvent: onPlaybackEvent,
    );
  }
}
