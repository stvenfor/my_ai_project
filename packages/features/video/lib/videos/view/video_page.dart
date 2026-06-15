import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频')),
      body: const Center(child: Text('Video 模块')),
    );
  }
}
