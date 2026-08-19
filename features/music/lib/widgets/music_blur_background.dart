import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:module_music/model/local_song.dart';

/// 全屏模糊背景（专辑图 + BackdropFilter）。
class MusicBlurBackground extends StatelessWidget {
  const MusicBlurBackground({super.key, required this.song});

  final LocalSong song;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'music-bg-${song.id}',
          child: _BackgroundImage(song: song),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: 0.54)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withValues(alpha: 0.1)),
        ),
      ],
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({required this.song});

  final LocalSong song;

  @override
  Widget build(BuildContext context) {
    if (song.hasNetworkCover) {
      return Image.network(
        song.albumArtUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }
    if (song.hasAssetCover) {
      return Image.asset(
        song.albumArtAsset!,
        package: MusicAssets.package,
        fit: BoxFit.cover,
      );
    }
    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      MusicAssets.defaultBackground,
      package: MusicAssets.package,
      fit: BoxFit.cover,
    );
  }
}
