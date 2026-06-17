import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/utils/app_video_player.dart';
import 'package:video_player/video_player.dart';

/// 横屏全屏播放（复用同一 [VideoPlayerController]）。
class ShortVideoLandscapePage extends StatefulWidget {
  const ShortVideoLandscapePage({
    super.key,
    required this.item,
    required this.controller,
  });

  final ShortVideoItem item;
  final VideoPlayerController controller;

  @override
  State<ShortVideoLandscapePage> createState() => _ShortVideoLandscapePageState();

  static Future<void> open(
    BuildContext context, {
    required ShortVideoItem item,
    required VideoPlayerController controller,
  }) async {
    if (controller.value.isInitialized && !controller.value.isPlaying) {
      await controller.play();
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ShortVideoLandscapePage(
          item: item,
          controller: controller,
        ),
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

class _ShortVideoLandscapePageState extends State<ShortVideoLandscapePage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    _ensurePlaying();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _ensurePlaying() async {
    final controller = widget.controller;
    if (!controller.value.isInitialized) return;
    if (!controller.value.isPlaying) {
      await controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final ready = controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!ready)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            )
          else
            Center(child: AppVideoPlayer.view(controller, fit: BoxFit.contain)),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
