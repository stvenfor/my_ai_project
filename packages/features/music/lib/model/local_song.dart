import 'package:flutter/material.dart';

/// 本地/远程歌曲模型。
class LocalSong {
  const LocalSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioUrl,
    this.duration = Duration.zero,
    this.albumArtAsset,
    this.albumArtUrl,
    this.placeholderColor,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final Duration duration;
  final String? albumArtAsset;
  final String? albumArtUrl;
  final Color? placeholderColor;

  bool get hasNetworkCover =>
      albumArtUrl != null && albumArtUrl!.isNotEmpty;

  bool get hasAssetCover =>
      albumArtAsset != null && albumArtAsset!.isNotEmpty;
}

enum MusicPlayerState { stopped, playing, paused }

abstract final class MusicAssets {
  static const package = 'module_music';
  static const defaultCover = 'assets/defaults/music_record.jpeg';
  static const defaultBackground = 'assets/defaults/lady.jpeg';

  static String assetPath(String name) => 'assets/defaults/$name';
}
