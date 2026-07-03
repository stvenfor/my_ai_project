import 'package:flutter/material.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/player/widgets/short_video_feed_view.dart';
import 'package:module_utils/player/widgets/short_video_single_view.dart';

/// 短视频播放器套件门面（P0）。
class ShortVideoPlayerKit {
  ShortVideoPlayerKit._();

  /// 竖滑 Feed。
  static Widget feed({
    required List<ShortVideoItem> items,
    int initialIndex = 0,
    List<DanmakuMockItem>? danmakuItems,
    ShortVideoOverlayBuilder? overlayBuilder,
    ShortVideoIndexCallback? onDoubleTapLike,
    ShortVideoPlaybackCallback? onPlaybackEvent,
    ScrollPhysics? physics,
  }) {
    return ShortVideoFeedView(
      items: items,
      initialIndex: initialIndex,
      danmakuItems: danmakuItems,
      overlayBuilder: overlayBuilder,
      onDoubleTapLike: onDoubleTapLike,
      onPlaybackEvent: onPlaybackEvent,
      physics: physics,
    );
  }

  /// 单条播放（可带列表上下文，支持继续上下滑）。
  static Widget single({
    required List<ShortVideoItem> items,
    required int initialIndex,
    List<DanmakuMockItem>? danmakuItems,
    ShortVideoOverlayBuilder? overlayBuilder,
    ShortVideoIndexCallback? onDoubleTapLike,
    ShortVideoPlaybackCallback? onPlaybackEvent,
  }) {
    return ShortVideoSingleView(
      items: items,
      initialIndex: initialIndex,
      danmakuItems: danmakuItems,
      overlayBuilder: overlayBuilder,
      onDoubleTapLike: onDoubleTapLike,
      onPlaybackEvent: onPlaybackEvent,
    );
  }
}
