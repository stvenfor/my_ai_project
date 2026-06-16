import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/video_play_page.dart';
import 'package:module_utils/module_utils.dart';

class VideoCardWidget extends StatelessWidget {
  const VideoCardWidget({
    super.key,
    required this.videoUrl,
    required this.coverUrl,
  });

  final String videoUrl;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to<void>(
        () => VideoPlayPage(videoUrl: videoUrl),
        transition: Transition.fadeIn,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: coverUrl != null && coverUrl!.isNotEmpty
                  ? CacheImageUtils.network(coverUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.black12),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}
