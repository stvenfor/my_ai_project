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
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.fullBleed,
      backgroundColor: Colors.black,
      navBar: const AppNavBar(
        showBackButton: true,
        style: AppNavBarStyle.dark,
      ),
      body: Center(
        child: _failed
            ? const Text('视频加载失败', style: TextStyle(color: Colors.white))
            : !_initialized || _controller == null
                ? const CircularProgressIndicator(color: Colors.white)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      AppVideoPlayer.view(_controller!),
                      AppVideoPlayer.playPauseOverlay(
                        controller: _controller!,
                        isPlaying: _controller!.value.isPlaying,
                        onToggle: _togglePlay,
                      ),
                    ],
                  ),
      ),
    );
  }
}
