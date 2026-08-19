import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/image_preview_page.dart';
import 'package:module_utils/module_utils.dart';

class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    super.key,
    required this.images,
    required this.postId,
  });

  final List<String> images;
  final String postId;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final count = images.length;

    if (count == 1) {
      return _SingleImage(url: images.first, images: images, index: 0);
    }
    if (count <= 3) {
      return _RowImages(urls: images);
    }
    if (count == 4) {
      return _GridImages(urls: images, crossAxisCount: 2);
    }
    return _GridImages(urls: images, crossAxisCount: 3);
  }
}

class _SingleImage extends StatelessWidget {
  const _SingleImage({
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
      onTap: () => _openPreview(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.62,
            maxHeight: 240,
          ),
          child: CacheImageUtils.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _openPreview(int i) {
    Get.to<void>(
      () => ImagePreviewPage(images: images, initialIndex: i),
      transition: Transition.fadeIn,
    );
  }
}

class _RowImages extends StatelessWidget {
  const _RowImages({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < urls.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _Thumb(url: urls[i], images: urls, index: i),
            ),
          ),
        ],
      ],
    );
  }
}

class _GridImages extends StatelessWidget {
  const _GridImages({
    required this.urls,
    required this.crossAxisCount,
  });

  final List<String> urls;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
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
