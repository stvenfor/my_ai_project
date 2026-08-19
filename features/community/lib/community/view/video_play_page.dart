import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class VideoPlayPage extends StatefulWidget {
  const VideoPlayPage({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
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
        autoPlay: true,
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
    return VideoPlaybackImmersiveScope(
      child: AppPageScaffold(
        layout: AppPageLayout.fullBleed,
        backgroundColor: Colors.black,
        navBar: const AppNavBar(
          showBackButton: true,
          style: AppNavBarStyle.dark,
        ),
        body: _failed
            ? const Center(
                child: Text('视频加载失败', style: TextStyle(color: Colors.white)),
              )
            : !_initialized || _controller == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: _togglePlay,
                        behavior: HitTestBehavior.opaque,
                        child: Center(child: AppVideoPlayer.view(_controller!)),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AppVideoControlsBar(controller: _controller!),
                      ),
                    ],
                  ),
      ),
    );
  }
}
