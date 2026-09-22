import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/image_preview_page.dart';
import 'package:module_utils/module_utils.dart';

/// 图片动态九宫格：最多 9 张、3 列；格子铺满无上下白板。
class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    super.key,
    required this.images,
    required this.postId,
  });

  final List<String> images;
  final String postId;

  static const maxCount = 9;
  static const _gap = 4.0;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 3;
        final cell =
            (constraints.maxWidth - _gap * (cols - 1)) / cols;
        final rows = (urls.length / cols).ceil();
        final height = rows * cell + (rows - 1) * _gap;

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: _gap,
              mainAxisSpacing: _gap,
              childAspectRatio: 1,
            ),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return _Thumb(url: urls[index], images: urls, index: index);
            },
          ),
        );
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
        child: LayoutBuilder(
          builder: (context, c) {
            return CacheImageUtils.network(
              url,
              fit: BoxFit.cover,
              width: c.maxWidth,
              height: c.maxHeight,
            );
          },
        ),
      ),
    );
  }
}
