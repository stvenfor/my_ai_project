import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/view/image_preview_page.dart';
import 'package:module_utils/module_utils.dart';

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({
    super.key,
    required this.url,
    required this.isSelf,
  });

  final String url;
  final bool isSelf;

  bool get _isLocal => url.startsWith('/') || url.startsWith('file:');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ImagePreviewPage(imageUrl: url),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
          child: _isLocal
              ? Image.file(
                  File(url.replaceFirst('file:', '')),
                  fit: BoxFit.cover,
                )
              : CacheImageUtils.network(
                  url,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
