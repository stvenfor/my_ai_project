import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';

class CommunityPage extends GetView<CommunityViewModel> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.title.value))),
      body: const Center(child: Text('Community MVVM 模块')),
    );
  }
}
