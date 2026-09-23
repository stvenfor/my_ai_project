import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';
import 'package:video_player/video_player.dart';

/// 社区视频播放页（Chewie controls + 横竖屏全屏）。
///
/// 小视频仍走 [ShortVideoPlayerKit]，本页不共用。
class VideoPlayPage extends StatefulWidget {
  const VideoPlayPage({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final video = await AppVideoPlayer.createController(
        widget.videoUrl,
        autoPlay: true,
      );
      if (!mounted) {
        await video.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white24,
        ),
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        errorBuilder: (context, errorMessage) => Center(
          child: Text(
            errorMessage.isEmpty ? '视频加载失败' : errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );

      setState(() {
        _videoController = video;
        _chewieController = chewie;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chewie = _chewieController;

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
            : chewie == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Chewie(controller: chewie),
      ),
    );
  }
}
