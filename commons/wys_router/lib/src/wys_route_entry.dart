import 'wys_route_interceptor.dart';

/// 方法路由 / 自定义跳转处理器（不打开 GetPage，只执行逻辑）。
typedef WysRouteHandler = void Function(
  String urlOrPath,
  Map<String, dynamic> arguments,
);

/// 页面类路由：映射到 GetX [GetPage.name]。
enum WysRouteTargetType {
  flutterPage,
  handler,
}

/// 单条路由元数据（注册表条目，非跳转引擎；引擎见 [WysRouter]）。
class WysRouteEntry {
  WysRouteEntry({
    required this.pattern,
    this.targetType = WysRouteTargetType.flutterPage,
    this.getPath,
    this.handler,
    this.interceptor,
  });

  /// 注册 key：完整 URL、`/mall/cart` 或原生 pageName（由 [WysRouter] 统一规范化）。
  final String pattern;

  final WysRouteTargetType targetType;

  /// [targetType] 为 [WysRouteTargetType.flutterPage] 时，返回 GetX 路由 path。
  final String? Function(String urlOrPath, Map<String, dynamic> arguments)?
      getPath;

  final WysRouteHandler? handler;

  /// 单路由拦截（在全局拦截器之后执行）。
  final WysRouteInterceptor? interceptor;
}
