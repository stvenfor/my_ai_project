import 'package:flutter/material.dart';
import 'package:module_music/model/local_song.dart';

/// 歌曲封面：网络 URL / asset / 彩色占位。
class MusicCoverAvatar extends StatelessWidget {
  const MusicCoverAvatar({
    super.key,
    required this.song,
    this.radius = 24,
    this.heroTag,
  });

  final LocalSong song;
  final double radius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (song.hasNetworkCover) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: song.placeholderColor ?? Colors.grey.shade800,
        backgroundImage: NetworkImage(song.albumArtUrl!),
      );
    } else if (song.hasAssetCover) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(
          song.albumArtAsset!,
          package: MusicAssets.package,
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: song.placeholderColor ?? Colors.grey.shade700,
        child: Icon(
          Icons.play_arrow,
          color: Colors.white.withValues(alpha: 0.9),
          size: radius,
        ),
      );
    }

    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }
}

/// 方形封面（播放页）。
class MusicCoverImage extends StatelessWidget {
  const MusicCoverImage({
    super.key,
    required this.song,
    this.size = 250,
    this.heroTag,
    this.fit = BoxFit.cover,
  });

  final LocalSong song;
  final double size;
  final String? heroTag;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (song.hasNetworkCover) {
      image = Image.network(
        song.albumArtUrl!,
        fit: fit,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _assetFallback(),
      );
    } else if (song.hasAssetCover) {
      image = Image.asset(
        song.albumArtAsset!,
        package: MusicAssets.package,
        fit: fit,
        width: size,
        height: size,
      );
    } else {
      image = _assetFallback();
    }

    final wrapped = heroTag == null
        ? image
        : Hero(
            tag: heroTag!,
            child: Material(
              borderRadius: BorderRadius.circular(5),
              elevation: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: image,
              ),
            ),
          );

    if (heroTag != null) return wrapped;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: wrapped,
    );
  }

  Widget _assetFallback() {
    return Image.asset(
      MusicAssets.defaultCover,
      package: MusicAssets.package,
      fit: fit,
      width: size,
      height: size,
    );
  }
}
