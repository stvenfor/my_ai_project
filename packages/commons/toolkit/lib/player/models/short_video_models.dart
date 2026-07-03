import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 短视频条目（业务层传入）。
@immutable
class ShortVideoItem {
  const ShortVideoItem({
    required this.id,
    required this.url,
    this.coverUrl,
    this.title,
    this.aspectRatio = 9 / 16,
  });

  final String id;
  final String url;
  final String? coverUrl;
  final String? title;
  final double aspectRatio;
}

/// Mock 弹幕条目。
@immutable
class DanmakuMockItem {
  const DanmakuMockItem({
    required this.text,
    this.colorArgb = 0xFFFFFFFF,
    this.topFactor = 0.2,
    this.durationMs = 8000,
  });

  final String text;
  final int colorArgb;
  final double topFactor;
  final int durationMs;
}

/// 播放事件（埋点 / 业务监听）。
enum PlaybackEventType {
  play,
  pause,
  complete,
  seek,
  error,
  networkReconnect,
}

@immutable
class PlaybackEvent {
  const PlaybackEvent({
    required this.type,
    required this.index,
    required this.itemId,
    this.position,
    this.message,
  });

  final PlaybackEventType type;
  final int index;
  final String itemId;
  final Duration? position;
  final String? message;
}

typedef ShortVideoOverlayBuilder = Widget Function(
  BuildContext context,
  int index,
  ShortVideoItem item,
);

typedef ShortVideoIndexCallback = void Function(int index);
typedef ShortVideoPlaybackCallback = void Function(PlaybackEvent event);
