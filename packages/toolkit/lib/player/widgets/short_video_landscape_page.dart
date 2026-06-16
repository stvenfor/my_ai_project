import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/utils/app_video_player.dart';
import 'package:video_player/video_player.dart';

/// 横屏全屏播放（复用同一 [VideoPlayerController]）。
class ShortVideoLandscapePage extends StatelessWidget {
  const ShortVideoLandscapePage({
    super.key,
    required this.item,
    required this.controller,
  });

  final ShortVideoItem item;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
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

  static Future<void> open(
    BuildContext context, {
    required ShortVideoItem item,
    required VideoPlayerController controller,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (!context.mounted) return;
    await Navigator.of(context).push(
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
