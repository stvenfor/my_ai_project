import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/realtime/realtime_connection_state.dart';
import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/realtime_initializer.dart';
import 'package:module_realtime/ui/realtime_notify_banner_controller.dart';
import 'package:module_route/route/route_path.dart';

/// Realtime 调试页。
class RealtimeDebugPage extends StatefulWidget {
  const RealtimeDebugPage({super.key});

  @override
  State<RealtimeDebugPage> createState() => _RealtimeDebugPageState();
}

class _RealtimeDebugPageState extends State<RealtimeDebugPage> {
  StreamSubscription<RealtimeEnvelope>? _presenceSub;
  String _lastPresenceUpdate = '（等待 presence.update）';

  @override
  void initState() {
    super.initState();
    final client = RealtimeInitializer.client;
    if (client != null) {
      _presenceSub = client
          .watchEvents(eventName: 'presence.update')
          .listen(_onPresenceUpdate);
    }
  }

  void _onPresenceUpdate(RealtimeEnvelope envelope) {
    final p = envelope.payload;
    final userId = p['userId']?.toString() ?? '?';
    final online = p['online'] == true;
    final count = p['onlineCount']?.toString() ?? '?';
    final device = p['device']?.toString();
    setState(() {
      _lastPresenceUpdate =
          'user=$userId online=$online count=$count${device != null ? ' device=$device' : ''}';
    });
  }

  void _simulateNotifyBanner() {
    if (!Get.isRegistered<RealtimeNotifyBannerController>()) return;
    final controller = Get.find<RealtimeNotifyBannerController>();
    final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
    controller.showBanner(
      RealtimeNotifyBannerData(
        notifyId: 'debug_$stamp',
        title: 'Realtime 测试通知 $stamp',
        body: '这是一条模拟 WebSocket sys.notify 顶部横幅消息',
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!Get.isRegistered<RealtimeNotifyBannerController>()) return;
      Get.find<RealtimeNotifyBannerController>().showBanner(
        RealtimeNotifyBannerData(
          notifyId: 'debug_${stamp + 1}',
          title: '排队测试通知',
          body: '上一条消失后应自动展示本条',
        ),
      );
    });
  }

  @override
  void dispose() {
    unawaited(_presenceSub?.cancel());
    super.dispose();
  }

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
              const SizedBox(height: 12),
              Text('presence.update: $_lastPresenceUpdate'),
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
                title: const Text('订阅 sys.notify + presence.bulk'),
                onTap: () => client.subscribeTopics([
                  RealtimeTopics.sysNotify,
                  RealtimeTopics.presenceBulk,
                ]),
              ),
              ListTile(
                title: const Text('上报 presence.report（广播给其他在线用户）'),
                subtitle: const Text('Go 处理后向 presence.bulk 推送 presence.update'),
                onTap: () => client.sendEvent(
                  topic: RealtimeTopics.presenceBulk,
                  eventName: 'presence.report',
                  payload: {
                    'online': true,
                    'device': Platform.operatingSystem,
                  },
                ),
              ),
              ListTile(
                title: const Text('上报 presence.report（离线）'),
                onTap: () => client.sendEvent(
                  topic: RealtimeTopics.presenceBulk,
                  eventName: 'presence.report',
                  payload: {
                    'online': false,
                    'device': Platform.operatingSystem,
                  },
                ),
              ),
              if (kDebugMode) ...[
                const Divider(height: 32),
                ListTile(
                  title: const Text('模拟 sys.notify Banner'),
                  subtitle: const Text('验证顶部滑入、自动消失与消息排队'),
                  onTap: _simulateNotifyBanner,
                ),
                ListTile(
                  title: const Text('进入 Mock 直播房'),
                  trailing: const Icon(Icons.live_tv),
                  onTap: () => Get.toNamed(RoutePath.liveRoom, arguments: 'mock_room_001'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
