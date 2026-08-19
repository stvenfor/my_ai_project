import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频底部控制条：播放/暂停、进度条、当前时间/总时长。
class AppVideoControlsBar extends StatefulWidget {
  const AppVideoControlsBar({
    super.key,
    required this.controller,
    this.activeColor = Colors.white,
    this.padding = const EdgeInsets.fromLTRB(8, 0, 12, 8),
  });

  final VideoPlayerController controller;
  final Color activeColor;
  final EdgeInsets padding;

  @override
  State<AppVideoControlsBar> createState() => _AppVideoControlsBarState();
}

class _AppVideoControlsBarState extends State<AppVideoControlsBar> {
  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(covariant AppVideoControlsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTick);
      _controller.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  Future<void> _seekTo(double value) async {
    await _controller.seekTo(Duration(milliseconds: value.round()));
  }

  static String formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.value;
    if (!value.isInitialized) return const SizedBox.shrink();

    final duration = value.duration;
    final position = value.position;
    final totalMs = duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, totalMs > 0 ? totalMs : 0);
    final isPlaying = value.isPlaying;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      child: Padding(
        padding: widget.padding,
        child: Row(
          children: [
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.activeColor,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: widget.activeColor,
                  inactiveTrackColor: widget.activeColor.withValues(alpha: 0.35),
                  thumbColor: widget.activeColor,
                ),
                child: Slider(
                  value: totalMs > 0 ? posMs.toDouble() : 0,
                  max: totalMs > 0 ? totalMs.toDouble() : 1,
                  onChanged: totalMs > 0 ? _seekTo : null,
                ),
              ),
            ),
            Text(
              '${formatDuration(position)} / ${formatDuration(duration)}',
              style: TextStyle(
                color: widget.activeColor,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
