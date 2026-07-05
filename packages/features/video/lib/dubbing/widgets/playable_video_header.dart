import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_utils/module_utils.dart';
import 'package:video_player/video_player.dart';

/// 详情页顶部可播放视频区（沉浸式铺满，字幕与水印叠加）。
class PlayableVideoHeader extends StatefulWidget {
  const PlayableVideoHeader({
    super.key,
    required this.videoUrl,
    this.height,
    this.autoPlay = true,
    this.showBackButton = true,
    this.showWatermark = true,
    this.subtitleEn,
    this.subtitleZh,
    this.onBack,
  });

  final String videoUrl;
  final double? height;
  final bool autoPlay;
  final bool showBackButton;
  final bool showWatermark;
  final String? subtitleEn;
  final String? subtitleZh;
  final VoidCallback? onBack;

  @override
  State<PlayableVideoHeader> createState() => _PlayableVideoHeaderState();
}

class _PlayableVideoHeaderState extends State<PlayableVideoHeader> {
  VideoPlayerController? _controller;
  var _initialized = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = await AppVideoPlayer.createNetworkController(
        widget.videoUrl,
        autoPlay: widget.autoPlay,
      );
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _initialized = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? MediaQuery.sizeOf(context).width * 9 / 16;

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: _buildVideoBody(),
          ),
          if (widget.showBackButton)
            Positioned(
              top: AppSafeInsets.top(context) + 4,
              left: 4,
              child: IconButton(
                onPressed: widget.onBack ?? () => Get.back<void>(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          if (widget.showWatermark)
            Positioned(
              top: AppSafeInsets.top(context) + 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '英语趣配音',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      'FUN DUBBING',
                      style: TextStyle(color: Colors.white70, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.subtitleEn != null || widget.subtitleZh != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 48,
              child: Column(
                children: [
                  if (widget.subtitleEn != null)
                    Text(
                      widget.subtitleEn!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  if (widget.subtitleZh != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitleZh!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoBody() {
    if (_failed) {
      return const Center(
        child: Text('视频加载失败', style: TextStyle(color: Colors.white70)),
      );
    }
    if (!_initialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final controller = _controller!;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          behavior: HitTestBehavior.opaque,
          child: AppVideoPlayer.view(controller, fit: BoxFit.cover),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AppVideoControlsBar(controller: controller),
        ),
      ],
    );
  }
}
