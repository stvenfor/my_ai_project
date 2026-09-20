import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:wys_router/src/route/route_path.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AppPageScaffold(
      navBar: const AppNavBar(title: '直播'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '进入直播房联调 Realtime 信令',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: tokens.body,
                  fontFamily: VercelTypography.fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Get.toNamed(
                  RoutePath.liveRoom,
                  arguments: 'mock_room_001',
                ),
                child: const Text('进入 Mock 直播房'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
