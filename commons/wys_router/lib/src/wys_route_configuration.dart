import 'wys_route_entry.dart';
import 'wys_route_interceptor.dart';

/// 启动时注入：scheme、未匹配页、默认跳转实现等。
class WysRouteConfiguration {
  WysRouteConfiguration({
    this.scheme = 'xiaomao',
    this.pendingRoute = '/pending',
    this.routes = const [],
    this.globalInterceptors = const [],
    this.onUnknownRoute,
  });

  /// 与 [LinkingConfig.customScheme]（`xiaomao`）对齐；Flutter 内跳转以 path 为准。
  final String scheme;

  /// 未注册路由时的 GetX path（壳工程可未注册，优先用 [onUnknownRoute]）。
  final String pendingRoute;

  final List<WysRouteEntry> routes;

  final List<WysRouteInterceptor> globalInterceptors;

  /// 自定义未知路由处理；返回 null 则走 [pendingRoute]。
  final Future<dynamic> Function(
    String urlOrPath,
    Map<String, dynamic> arguments,
  )? onUnknownRoute;
}