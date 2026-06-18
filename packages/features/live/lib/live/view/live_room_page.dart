import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/realtime/realtime_connection_state.dart';
import 'package:module_core/service/app_realtime_client.dart';
import 'package:module_realtime/config/realtime_config.dart';

class LiveRoomController extends GetxController {
  LiveRoomController({required this.roomId});

  final String roomId;
  final signals = <String>[].obs;
  final connectionLabel = ''.obs;
  StreamSubscription<RealtimeConnectionState>? _stateSub;
  StreamSubscription<dynamic>? _signalSub;
  StreamSubscription<dynamic>? _roomStateSub;

  AppRealtimeClient? get _client =>
      Get.isRegistered<AppRealtimeClient>() ? Get.find<AppRealtimeClient>() : null;

  @override
  void onInit() {
    super.onInit();
    final client = _client;
    if (client == null) return;

    client.setKeepAliveInBackground(true);
    connectionLabel.value = client.currentState.label;
    _stateSub = client.connectionState.listen((s) {
      connectionLabel.value = s.label;
    });

    client.subscribeTopics([
      RealtimeTopics.liveSignal(roomId),
      RealtimeTopics.liveRoomState(roomId),
    ]);

    _signalSub = client.watchTopic(RealtimeTopics.liveSignal(roomId)).listen((e) {
      signals.insert(0, '[signal] ${e.eventName} seq=${e.seq} ${e.payload}');
      if (signals.length > 30) signals.removeRange(30, signals.length);
    });

    _roomStateSub = client.watchTopic(RealtimeTopics.liveRoomState(roomId)).listen((e) {
      signals.insert(0, '[state] ${e.eventName} seq=${e.seq}');
      if (signals.length > 30) signals.removeRange(30, signals.length);
    });
  }

  @override
  void onClose() {
    _stateSub?.cancel();
    _signalSub?.cancel();
    _roomStateSub?.cancel();
    final client = _client;
    client?.setKeepAliveInBackground(false);
    client?.unsubscribeTopics([
      RealtimeTopics.liveSignal(roomId),
      RealtimeTopics.liveRoomState(roomId),
    ]);
    super.onClose();
  }

  Future<void> sendMockSignal() async {
    await _client?.sendEvent(
      topic: RealtimeTopics.liveSignal(roomId),
      eventName: 'live.join',
      payload: {'roomId': roomId},
    );
  }
}

class LiveRoomPage extends StatelessWidget {
  const LiveRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final roomId = Get.arguments?.toString() ?? 'mock_room';
    final tag = 'live_$roomId';
    if (!Get.isRegistered<LiveRoomController>(tag: tag)) {
      Get.put(LiveRoomController(roomId: roomId), tag: tag);
    }
    final controller = Get.find<LiveRoomController>(tag: tag);

    return AppPageScaffold(
      navBar: AppNavBar(title: '直播 $roomId', showBackButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'WS: ${controller.connectionLabel.value} · paused 保持连接',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton(
              onPressed: controller.sendMockSignal,
              child: const Text('发送 join 信令'),
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.signals.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(
                    controller.signals[i],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
