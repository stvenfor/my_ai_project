import 'dart:io';

import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({super.key, required this.imageUrl});

  final String imageUrl;

  bool get _isLocal =>
      imageUrl.startsWith('/') || imageUrl.startsWith('file:');

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.fullBleed,
      backgroundColor: Colors.black,
      navBar: const AppNavBar(
        showBackButton: true,
        style: AppNavBarStyle.dark,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: _isLocal
              ? Image.file(
                  File(imageUrl.replaceFirst('file:', '')),
                  fit: BoxFit.contain,
                )
              : CacheImageUtils.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
