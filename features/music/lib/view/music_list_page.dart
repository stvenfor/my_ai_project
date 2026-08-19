import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/model/local_song.dart';
import 'package:module_music/theme/music_theme.dart';
import 'package:module_music/widgets/music_cover_image.dart';
import 'package:module_music/widgets/music_mini_player_bar.dart';
import 'package:module_route/route/route_path.dart';

class MusicListPage extends GetView<MusicPlaybackController> {
  const MusicListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: musicListDarkTheme,
      child: Obx(() {
        controller.playerState.value;
        controller.currentIndex.value;
        final miniBarInset = MusicMiniPlayerBar.bottomInsetForSession();

        return AppPageScaffold(
          layout: AppPageLayout.edgeToEdge,
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: miniBarInset),
                child: Column(
                  children: [
                    AppNavBar(
                      title: '音频列表',
                      style: AppNavBarStyle.dark,
                      showBackButton: true,
                      onBack: () => Get.back<void>(),
                      actions: [
                        if (controller.hasActiveSession)
                          TextButton(
                            onPressed: () =>
                                Get.toNamed<void>(RoutePath.musicNowPlaying),
                            child: const Text('Now Playing'),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Obx(() {
                        final songs = controller.songs.toList();
                        return ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return _SongListTile(
                              song: song,
                              onTap: () async {
                                await controller.playAt(index);
                                await Get.toNamed<void>(
                                  RoutePath.musicNowPlaying,
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const MusicMiniPlayerBar(),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: miniBarInset),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF4DD0C8),
              onPressed: () async {
                await controller.shuffleAndPlay();
                await Get.toNamed<void>(RoutePath.musicNowPlaying);
              },
              child: const Icon(Icons.shuffle, color: Colors.white),
            ),
          ),
        );
      }),
    );
  }
}

class _SongListTile extends StatelessWidget {
  const _SongListTile({
    required this.song,
    required this.onTap,
  });

  final LocalSong song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MusicCoverAvatar(
        song: song,
        heroTag: 'music-cover-${song.id}',
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'By ${song.artist}',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      ),
      onTap: onTap,
    );
  }
}
