import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '直播'),
      body: const Center(child: Text('Live 模块')),
    );
  }
}
