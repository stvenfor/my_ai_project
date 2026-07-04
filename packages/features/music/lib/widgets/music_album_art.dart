import 'package:flutter/material.dart';
import 'package:module_music/model/local_song.dart';
import 'package:module_music/widgets/music_cover_image.dart';

/// 封面 Hero + 弹性入场 + 底部迷你进度条。
class MusicAlbumArt extends StatefulWidget {
  const MusicAlbumArt({
    super.key,
    required this.song,
    required this.position,
    required this.duration,
  });

  final LocalSong song;
  final Duration position;
  final Duration duration;

  @override
  State<MusicAlbumArt> createState() => _MusicAlbumArtState();
}

class _MusicAlbumArtState extends State<MusicAlbumArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return SizedBox(
          width: 250 * _scale.value,
          height: 250 * _scale.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          MusicCoverImage(
            song: widget.song,
            size: 250,
            heroTag: 'music-cover-${widget.song.id}',
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
