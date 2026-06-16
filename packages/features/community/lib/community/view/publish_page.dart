import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';

class PublishPage extends StatelessWidget {
  const PublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: AppNavBar(
        title: '发布动态',
        showBackButton: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '发布动态功能开发中',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '后续可接入发帖接口',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
