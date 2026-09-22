import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/image_preview_page.dart';
import 'package:module_utils/module_utils.dart';

/// 图片动态九宫格：最多 9 张、3 列；不足时用 seed 随机图补齐。
class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    super.key,
    required this.images,
    required this.postId,
  });

  final List<String> images;
  final String postId;

  static const maxCount = 9;

  /// 列表展示用：取已有 URL，不足 9 张用 picsum 按 postId 补齐（确定性「随机」）。
  static List<String> nineGridUrls({
    required String postId,
    required List<String> images,
  }) {
    final out = <String>[];
    for (final u in images) {
      if (u.isEmpty) continue;
      out.add(u);
      if (out.length >= maxCount) return out;
    }
    var i = out.length;
    while (out.length < maxCount) {
      out.add('https://picsum.photos/seed/${postId}_$i/400/400');
      i++;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final urls = nineGridUrls(postId: postId, images: images);
    if (urls.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return _Thumb(url: urls[index], images: urls, index: index);
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.url,
    required this.images,
    required this.index,
  });

  final String url;
  final List<String> images;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to<void>(
          () => ImagePreviewPage(images: images, initialIndex: index),
          transition: Transition.fadeIn,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CacheImageUtils.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
