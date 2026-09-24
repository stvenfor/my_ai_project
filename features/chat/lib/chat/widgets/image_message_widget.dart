import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/view/image_preview_page.dart';
import 'package:module_utils/module_utils.dart';

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({
    super.key,
    required this.url,
  });

  final String url;

  bool get _isLocal => url.startsWith('/') || url.startsWith('file:');

  static const double _maxW = 200;
  static const double _maxH = 260;
  static const double _minSide = 96;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ImagePreviewPage(imageUrl: url),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _minSide,
            maxWidth: _maxW,
            minHeight: _minSide,
            maxHeight: _maxH,
          ),
          child: _isLocal
              ? Image.file(
                  File(url.replaceFirst(RegExp(r'^file://'), '')),
                  width: _maxW,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : CacheImageUtils.network(
                  url,
                  width: _maxW,
                  height: _maxH,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: _minSide,
      height: _minSide,
      color: ChatTheme.fillSecondary,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: ChatTheme.labelTertiary,
      ),
    );
  }
}
