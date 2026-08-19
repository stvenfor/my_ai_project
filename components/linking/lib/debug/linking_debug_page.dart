import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_linking/config/linking_config.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/deeplink/deeplink_route_table.dart';
import 'package:module_linking/linking_initializer.dart';
import 'package:module_linking/models/push_payload.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_linking/push/push_service.dart';

/// Deeplink / Push 调试页（kDebugMode）。
class LinkingDebugPage extends StatelessWidget {
  const LinkingDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final push = LinkingInitializer.pushService;
    final privacy = Get.find<PrivacyConsentService>();
    final navigator = Get.find<AppNavigator>();

    return AppPageScaffold(
      navBar: const AppNavBar(title: '链接与推送调试', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'mockPush=${LinkingConfig.mockPush} · privacy=${privacy.isGranted}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text('Mock Deeplink', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...DeeplinkRouteTable.mockLinks().map(
            (url) => ListTile(
              title: Text(url, style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                final parser = Get.find<AppLinkParser>();
                final intent = parser.parse(url);
                if (intent != null) {
                  navigator.navigate(intent);
                }
              },
            ),
          ),
          const Divider(height: 32),
          const Text('Mock Push（前台 Banner）', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _PushMockTile(
            title: '小视频列表',
            push: push,
            payload: PushPayload(
              title: '你有新视频',
              body: '点击查看小视频列表',
              msgId: 'mock_push_short_list',
              deeplink: 'https://${LinkingConfig.productionHost}/app/video/short',
            ),
          ),
          _PushMockTile(
            title: '小视频播放',
            push: push,
            payload: PushPayload(
              title: '热门视频',
              body: '立即播放 index=1',
              msgId: 'mock_push_short_play',
              deeplink:
                  'https://${LinkingConfig.productionHost}/app/video/short/play?index=1',
            ),
          ),
          _PushMockTile(
            title: '社区',
            push: push,
            payload: PushPayload(
              title: '社区动态',
              body: '有人 @ 了你',
              msgId: 'mock_push_community',
              deeplink: 'https://${LinkingConfig.productionHost}/app/community',
            ),
          ),
          _PushMockTile(
            title: '聊天详情',
            push: push,
            payload: PushPayload(
              title: '新消息',
              body: 'MockUser: 你好',
              msgId: 'mock_push_chat',
              deeplink:
                  'https://${LinkingConfig.productionHost}/app/chat/detail?peerName=MockUser',
            ),
          ),
          if (push != null) ...[
            const Divider(height: 32),
            ListTile(
              title: const Text('上报 Alias (mock)'),
              subtitle: const Text('user_mock_001'),
              onTap: () => push.setAlias('user_mock_001'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PushMockTile extends StatelessWidget {
  const _PushMockTile({
    required this.title,
    required this.push,
    required this.payload,
  });

  final String title;
  final PushService? push;
  final PushPayload payload;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(payload.deeplink ?? ''),
      trailing: const Icon(Icons.notifications),
      onTap: push == null
          ? null
          : () => push!.simulatePush(payload, foreground: true),
    );
  }
}