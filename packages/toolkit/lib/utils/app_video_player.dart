import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频播放封装（唯一依赖 video_player 的文件）。
class AppVideoPlayer {
  AppVideoPlayer._();

  static Future<VideoPlayerController> createNetworkController(
    String url, {
    bool autoPlay = false,
    bool looping = false,
  }) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(looping);
    if (autoPlay) await controller.play();
    return controller;
  }

  static Widget view(
    VideoPlayerController controller, {
    BoxFit fit = BoxFit.contain,
  }) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio == 0
          ? 16 / 9
          : controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
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
