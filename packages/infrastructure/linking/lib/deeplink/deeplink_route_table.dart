import 'package:module_linking/config/linking_config.dart';
import 'package:module_linking/models/app_route_intent.dart';
import 'package:module_route/route/route_path.dart';

/// Mock 4 条 Deeplink 路由表（先切 Tab 再 push 子页）。
class DeeplinkRouteTable {
  DeeplinkRouteTable._();

  static AppRouteIntent? resolve(Uri uri) {
    if (!uri.path.startsWith(LinkingConfig.appPathPrefix)) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.first != 'app') return null;

    final subPath = segments.skip(1).join('/');
    final query = uri.queryParameters;

    return switch (subPath) {
      'video/short' => AppRouteIntent(
          tabModuleId: 'settings',
          route: RoutePath.shortVideo,
          source: LinkSource.deeplink,
          originalUrl: uri.toString(),
        ),
      'video/short/play' => AppRouteIntent(
          tabModuleId: 'settings',
          route: RoutePath.shortVideoPlay,
          arguments: _playArgs(query),
          source: LinkSource.deeplink,
          originalUrl: uri.toString(),
        ),
      'community' => AppRouteIntent(
          tabModuleId: 'community',
          route: RoutePath.community,
          source: LinkSource.deeplink,
          originalUrl: uri.toString(),
        ),
      'chat/detail' => AppRouteIntent(
          tabModuleId: 'chat',
          route: RoutePath.chatDetail,
          arguments: _mockConversation(query),
          source: LinkSource.deeplink,
          originalUrl: uri.toString(),
        ),
      _ => null,
    };
  }

  static Map<String, dynamic> _playArgs(Map<String, String> query) {
    final index = int.tryParse(query['index'] ?? query['id'] ?? '0') ?? 0;
    return {'initialIndex': index, ...query};
  }

  static Map<String, dynamic> _mockConversation(Map<String, String> query) {
    final peerId = query['peerId'] ?? 'mock_peer';
    final peerName = query['peerName'] ?? '推送会话';
    return {
      'id': query['id'] ?? 'conv_mock_push',
      'peerId': peerId,
      'peerName': peerName,
      'peerAvatar': query['avatar'] ?? 'https://picsum.photos/seed/$peerId/100/100',
      'lastMessage': query['lastMessage'] ?? '来自 Push/Deeplink 的 mock 会话',
      'lastMessageTime': DateTime.now().toIso8601String(),
      'isOnline': true,
      'unreadCount': int.tryParse(query['unread'] ?? '1') ?? 1,
    };
  }

  /// 调试页展示可用 mock 链接。
  static List<String> mockLinks() => [
        'https://${LinkingConfig.productionHost}/app/video/short',
        'https://${LinkingConfig.productionHost}/app/video/short/play?index=1',
        'https://${LinkingConfig.productionHost}/app/community',
        'https://${LinkingConfig.productionHost}/app/chat/detail?peerName=MockUser',
        '${LinkingConfig.customScheme}://app/video/short',
        'https://${LinkingConfig.productionHost}/about',
      ];
}
