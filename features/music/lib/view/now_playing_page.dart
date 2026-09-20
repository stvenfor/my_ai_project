import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/model/local_song.dart';
import 'package:module_music/widgets/music_album_art.dart';
import 'package:module_music/widgets/music_blur_background.dart';
import 'package:module_music/widgets/music_control_button.dart';

class NowPlayingPage extends GetView<MusicPlaybackController> {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final song = controller.currentSong;
      if (song == null) {
        return AppPageScaffold(
          navBar: const AppNavBar(title: 'Now Playing', showBackButton: true),
          body: const Center(child: Text('暂无播放歌曲')),
        );
      }

      return AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        navBar: AppNavBar(
          title: 'Now Playing',
          showBackButton: true,
          onBack: () => Get.back<void>(),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MusicBlurBackground(song: song),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final position = controller.position.value;
                  final duration = controller.duration.value;
                  return MusicAlbumArt(
                    song: song,
                    position: position,
                    duration: duration,
                  );
                }),
                Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _PlayerControls(song: song),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PlayerControls extends GetView<MusicPlaybackController> {
  const _PlayerControls({required this.song});

  final LocalSong song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = VercelTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          song.title,
          style: theme.textTheme.headlineSmall?.copyWith(color: tokens.ink),
          textAlign: TextAlign.center,
        ),
        Text(
          song.artist,
          style: theme.textTheme.bodySmall?.copyWith(color: tokens.mute),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final playing = controller.isPlaying;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MusicControlButton(
                icon: Icons.skip_previous,
                onPressed: controller.playPrevious,
              ),
              MusicControlButton(
                icon: playing ? Icons.pause : Icons.play_arrow,
                onPressed: controller.togglePlayPause,
              ),
              MusicControlButton(
                icon: Icons.skip_next,
                onPressed: controller.playNext,
              ),
            ],
          );
        }),
        Obx(() {
          final position = controller.position.value;
          final duration = controller.duration.value;
          if (duration.inMilliseconds <= 0) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              Slider(
                value: position.inMilliseconds.toDouble(),
                max: duration.inMilliseconds.toDouble(),
                onChanged: controller.seekTo,
              ),
              Text(
                '${MusicPlaybackController.formatDuration(position)} / '
                '${MusicPlaybackController.formatDuration(duration)}',
                style: theme.textTheme.titleMedium?.copyWith(color: tokens.body),
              ),
            ],
          );
        }),
        const SizedBox(height: 20),
        Obx(() {
          final muted = controller.isMuted.value;
          return IconButton(
            onPressed: controller.toggleMute,
            icon: Icon(muted ? Icons.headset_off : Icons.headset),
            color: tokens.mute,
          );
        }),
      ],
    );
  }
}
