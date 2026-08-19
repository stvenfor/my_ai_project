import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '好友'),
      body: const Center(child: Text('Friend 模块')),
    );
  }
}
