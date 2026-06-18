import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/realtime/realtime_connection_state.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/realtime_initializer.dart';
import 'package:module_route/route/route_path.dart';

/// Realtime 调试页。
class RealtimeDebugPage extends StatelessWidget {
  const RealtimeDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = RealtimeInitializer.client;
    if (client == null) {
      return const AppPageScaffold(
        navBar: AppNavBar(title: 'Realtime 调试', showBackButton: true),
        body: Center(child: Text('Realtime 未初始化')),
      );
    }

    return AppPageScaffold(
      navBar: const AppNavBar(title: 'Realtime 调试', showBackButton: true),
      body: StreamBuilder<RealtimeConnectionState>(
        stream: client.connectionState,
        initialData: client.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data ?? client.currentState;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('mockGateway=${RealtimeConfig.useMockGateway}'),
              const SizedBox(height: 8),
              Text('state=${state.label}'),
              Text('lastSeq=${client.lastSeq}'),
              Text('reconnectCount=${client.reconnectCount}'),
              Text('queueDepth=${client.outboundQueueDepth}'),
              Text('keepAliveBg=${client.keepAliveInBackground}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => RealtimeInitializer.tryConnectIfReady(),
                child: const Text('连接 / 重连'),
              ),
              OutlinedButton(
                onPressed: () => client.disconnect(reason: 'debug'),
                child: const Text('断开'),
              ),
              const Divider(height: 32),
              ListTile(
                title: const Text('订阅 sys.notify'),
                onTap: () => client.subscribeTopics([RealtimeTopics.sysNotify]),
              ),
              ListTile(
                title: const Text('模拟发送 presence 事件'),
                onTap: () => client.sendEvent(
                  topic: RealtimeTopics.presenceBulk,
                  eventName: 'presence.report',
                  payload: {'online': true},
                ),
              ),
              if (kDebugMode)
                ListTile(
                  title: const Text('进入 Mock 直播房'),
                  trailing: const Icon(Icons.live_tv),
                  onTap: () => Get.toNamed(RoutePath.liveRoom, arguments: 'mock_room_001'),
                ),
            ],
          );
        },
      ),
    );
  }
}
