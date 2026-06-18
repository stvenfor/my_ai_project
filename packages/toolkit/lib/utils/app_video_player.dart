import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频播放封装（唯一依赖 video_player 的文件）。
class AppVideoPlayer {
  AppVideoPlayer._();

  static VideoPlayerOptions get _defaultOptions =>
      VideoPlayerOptions(mixWithOthers: true);

  static Future<VideoPlayerController> createNetworkController(
    String url, {
    bool autoPlay = false,
    bool looping = false,
  }) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: _defaultOptions,
    );
    await controller.initialize();
    controller.setLooping(looping);
    if (autoPlay) await controller.play();
    return controller;
  }

  /// 带 BoxFit 的视频画面（竖屏 cover / 横屏 contain 共用）。
  static Widget surface(
    VideoPlayerController controller, {
    BoxFit fit = BoxFit.contain,
  }) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final size = controller.value.size;
    final width = size.width > 0 ? size.width : 1280.0;
    final height = size.height > 0 ? size.height : 720.0;

    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: width,
        height: height,
        child: VideoPlayer(controller),
      ),
    );
  }

  static Widget view(
    VideoPlayerController controller, {
    BoxFit fit = BoxFit.contain,
  }) {
    return surface(controller, fit: fit);
  }

  static Widget playPauseOverlay({
    required VideoPlayerController controller,
    required VoidCallback onToggle,
    required bool isPlaying,
  }) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black26,
          alignment: Alignment.center,
          child: const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
        ),
      ),
    );
  }
}
