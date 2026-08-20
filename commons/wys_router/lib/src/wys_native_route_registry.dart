import 'package:flutter/foundation.dart';

/// 同一个 Flutter 路由在各原生平台对应的页面路径。
class WysNativeRoutePaths {
  const WysNativeRoutePaths({this.androidPath, this.iosPath, this.ohosPath});

  final String? androidPath;
  final String? iosPath;
  final String? ohosPath;

  String? pathFor(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => _nonEmpty(androidPath),
      TargetPlatform.iOS => _nonEmpty(iosPath),
      TargetPlatform.ohos => _nonEmpty(ohosPath),
      _ => null,
    };
  }

  bool get hasAnyPath =>
      _nonEmpty(androidPath) != null ||
      _nonEmpty(iosPath) != null ||
      _nonEmpty(ohosPath) != null;

  static String? _nonEmpty(String? value) {
    final path = value?.trim();
    return path == null || path.isEmpty ? null : path;
  }
}

/// Flutter 路由与原生页面路径的注册表。
///
/// 注册后，[WysRouter.routeURL] 会优先通过原生路由通道打开对应页面，
/// 未注册的路由仍按原有 GetX 路由处理。
abstract final class WysNativeRouteRegistry {
  WysNativeRouteRegistry._();

  static final Map<String, WysNativeRoutePaths> _routes =
      <String, WysNativeRoutePaths>{};

  static void register(
    String flutterRoute, {
    String? androidPath,
    String? iosPath,
    String? ohosPath,
  }) {
    final route = flutterRoute.trim();
    if (route.isEmpty) {
      throw ArgumentError('flutterRoute 不能为空');
    }
    final paths = WysNativeRoutePaths(
      androidPath: androidPath,
      iosPath: iosPath,
      ohosPath: ohosPath,
    );
    if (!paths.hasAnyPath) {
      throw ArgumentError('至少需要配置一个原生平台路径');
    }
    _routes[route] = paths;
  }

  static void registerAll(Map<String, WysNativeRoutePaths> routes) {
    for (final entry in routes.entries) {
      final paths = entry.value;
      register(
        entry.key,
        androidPath: paths.androidPath,
        iosPath: paths.iosPath,
        ohosPath: paths.ohosPath,
      );
    }
  }

  static void unregister(String flutterRoute) {
    _routes.remove(flutterRoute.trim());
  }

  static void clear() => _routes.clear();

  static String? nativePathFor(String flutterRoute) {
    return _routes[flutterRoute.trim()]?.pathFor(defaultTargetPlatform);
  }
}
