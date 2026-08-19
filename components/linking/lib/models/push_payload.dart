import 'package:module_linking/models/app_route_intent.dart';

/// 通用 Push Payload（极光 extras / 业务层均可映射）。
///
/// ```json
/// {
///   "title": "标题",
///   "body": "正文",
///   "msgId": "msg_001",
///   "deeplink": "https://xiaomaomain.com/app/video/short/play?index=0",
///   "extras": {
///     "route": "/app/video/short/play",
///     "params": {"index": "0"}
///   }
/// }
/// ```
class PushPayload {
  const PushPayload({
    required this.title,
    required this.body,
    this.msgId,
    this.deeplink,
    this.extras = const {},
    this.raw = const {},
  });

  final String title;
  final String body;
  final String? msgId;
  final String? deeplink;
  final Map<String, dynamic> extras;
  final Map<String, dynamic> raw;

  bool get hasNavigationTarget =>
      (deeplink != null && deeplink!.isNotEmpty) ||
      extras['route'] != null ||
      extras['deeplink'] != null;

  AppRouteIntent? toRouteIntent(AppRouteIntent Function(String url) parseUrl) {
    final link = deeplink ??
        extras['deeplink']?.toString() ??
        _routeToUrl(extras['route']?.toString());
    if (link == null || link.isEmpty) return null;
    final intent = parseUrl(link);
    return intent.copyWith(
      source: LinkSource.push,
      msgId: msgId ?? extras['msgId']?.toString(),
    );
  }

  static String? _routeToUrl(String? route) {
    if (route == null || route.isEmpty) return null;
    if (route.startsWith('http')) return route;
    if (route.startsWith('/app')) {
      return 'https://xiaomaomain.com$route';
    }
    return 'https://xiaomaomain.com/app$route';
  }

  factory PushPayload.fromMap(Map<String, dynamic> map) {
    final extrasRaw = map['extras'];
    final extras = extrasRaw is Map
        ? Map<String, dynamic>.from(extrasRaw)
        : <String, dynamic>{};

    return PushPayload(
      title: map['title']?.toString() ?? map['aps']?['alert']?['title']?.toString() ?? '通知',
      body: map['body']?.toString() ??
          map['content']?.toString() ??
          map['aps']?['alert']?['body']?.toString() ??
          '',
      msgId: map['msgId']?.toString() ?? extras['msgId']?.toString(),
      deeplink: map['deeplink']?.toString(),
      extras: extras,
      raw: Map<String, dynamic>.from(map),
    );
  }
}
