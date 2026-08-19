import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '直播'),
      body: Center(
        child: FilledButton(
          onPressed: () => Get.toNamed(
            RoutePath.liveRoom,
            arguments: 'mock_room_001',
          ),
          child: const Text('进入 Mock 直播房'),
        ),
      ),
    );
  }
}
