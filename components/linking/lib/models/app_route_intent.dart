/// 路由意图来源。
enum LinkSource {
  deeplink,
  push,
  mock,
}

/// 统一路由意图：Tab 切换 + 子页 push。
class AppRouteIntent {
  const AppRouteIntent({
    this.tabModuleId,
    required this.route,
    this.arguments,
    required this.source,
    this.originalUrl,
    this.msgId,
  });

  /// 主 Tab 模块 id：home / chat / community / settings
  final String? tabModuleId;

  /// GetX 路由名，如 [RoutePath.shortVideo]。
  final String route;

  final Object? arguments;

  final LinkSource source;

  final String? originalUrl;

  final String? msgId;

  AppRouteIntent copyWith({
    String? tabModuleId,
    String? route,
    Object? arguments,
    LinkSource? source,
    String? originalUrl,
    String? msgId,
  }) {
    return AppRouteIntent(
      tabModuleId: tabModuleId ?? this.tabModuleId,
      route: route ?? this.route,
      arguments: arguments ?? this.arguments,
      source: source ?? this.source,
      originalUrl: originalUrl ?? this.originalUrl,
      msgId: msgId ?? this.msgId,
    );
  }

  Map<String, dynamic> toAnalyticsMap() => {
        'tabModuleId': tabModuleId,
        'route': route,
        'source': source.name,
        'originalUrl': originalUrl,
        'msgId': msgId,
      };
}
