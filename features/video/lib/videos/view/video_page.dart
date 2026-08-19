import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '视频'),
      body: const Center(child: Text('Video 模块')),
    );
  }
}
