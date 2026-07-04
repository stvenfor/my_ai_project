import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/theme/music_theme.dart';
import 'package:module_music/widgets/music_cover_image.dart';
import 'package:module_route/route/route_path.dart';

/// 首页 Tab（MainPage 底部栏）与音频列表页底部迷你播放条。
class MusicMiniPlayerBar extends GetView<MusicPlaybackController> {
  const MusicMiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.playerState.value;
      controller.currentIndex.value;
      if (!controller.hasActiveSession) {
        return const SizedBox.shrink();
      }
      final song = controller.currentSong!;
      final position = controller.position.value;
      final total = controller.duration.value;
      final playing = controller.isPlaying;
      final progress = total.inMilliseconds > 0
          ? position.inMilliseconds / total.inMilliseconds
          : 0.0;

      return Material(
        elevation: 8,
        color: const Color(0xFF1A1A1A),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 2,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4DD0C8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.togglePlayPause,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MusicCoverAvatar(song: song, radius: 22),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.toNamed<void>(RoutePath.musicNowPlaying),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'By ${song.artist}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                          if (total.inMilliseconds > 0)
                            Text(
                              '${MusicPlaybackController.formatDuration(position)} / '
                              '${MusicPlaybackController.formatDuration(total)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.stop,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 列表/首页底部留白，避免内容被迷你条遮挡。
  static double bottomInset(bool visible) =>
      visible ? musicMiniPlayerBarHeight : 0;

  /// MainPage 底部 Tab 栏占位（迷你条叠在 Tab 上方，计入首页滚动留白）。
  static double mainTabBarBottomOffset(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 600) return 0;
    return musicMainTabBarHeight;
  }

  /// 根据当前播放会话计算底部留白（Obx 内调用前需已订阅 controller obs）。
  static double bottomInsetForSession() {
    if (!Get.isRegistered<MusicPlaybackController>()) return 0;
    final playback = Get.find<MusicPlaybackController>();
    playback.playerState.value;
    playback.currentIndex.value;
    return bottomInset(playback.hasActiveSession);
  }

  /// 首页 Tab：迷你条高度 + Tab 栏占位。
  static double bottomInsetForHomeSession(BuildContext context) {
    final miniBar = bottomInsetForSession();
    if (miniBar == 0) return 0;
    return miniBar + mainTabBarBottomOffset(context);
  }
}
