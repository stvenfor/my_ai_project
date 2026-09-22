import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class ImagePreviewPage extends StatefulWidget {
  const ImagePreviewPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  /// 网络 URL 或本地文件路径。
  final List<String> images;
  final int initialIndex;

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static ImageProvider _provider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  static bool _isNetwork(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.fullBleed,
      backgroundColor: Colors.black,
      navBar: AppNavBar(
        title: '${_currentIndex + 1}/${widget.images.length}',
        showBackButton: true,
        style: AppNavBarStyle.dark,
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.images.length,
        builder: (context, index) {
          final path = widget.images[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: _provider(path),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: path),
            errorBuilder: (_, __, ___) => Center(
              child: _isNetwork(path)
                  ? CacheImageUtils.network(path, fit: BoxFit.contain)
                  : Image.file(File(path), fit: BoxFit.contain),
            ),
          );
        },
        onPageChanged: (index) => setState(() => _currentIndex = index),
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
