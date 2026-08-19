import 'package:flutter/material.dart';
import 'package:module_common_ui/theme/app_theme.dart';

/// 视频播放页沉浸式作用域：进入时隐藏状态栏（时间/电量等），离开时恢复。
class VideoPlaybackImmersiveScope extends StatefulWidget {
  const VideoPlaybackImmersiveScope({super.key, required this.child});

  final Widget child;

  @override
  State<VideoPlaybackImmersiveScope> createState() =>
      _VideoPlaybackImmersiveScopeState();
}

class _VideoPlaybackImmersiveScopeState extends State<VideoPlaybackImmersiveScope> {
  Brightness _brightness = Brightness.light;

  @override
  void initState() {
    super.initState();
    ImmersiveHelper.applyPlayback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
  }

  @override
  void dispose() {
    ImmersiveHelper.restoreFromPlayback(brightness: _brightness);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
