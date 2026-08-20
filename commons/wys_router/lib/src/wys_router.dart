import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'wys_capability_routes.dart';
import 'wys_native_page_name_map.dart';
import 'wys_native_route_registry.dart';
import 'wys_route.dart';
import 'wys_route_configuration.dart';
import 'wys_route_interceptor.dart';
import 'wys_url_utils.dart';

/// 统一 URL 跳转入口（Dart 侧对齐 iOS WysRouter / gaodun GdRouter）。
abstract final class WysRouter {
  WysRouter._();

  static WysRouteConfiguration? _configuration;
  static final Map<String, WysRoute> _routes = {};
  static final List<WysRouteInterceptor> _globalInterceptors = [];
  static const MethodChannel _nativeRouteChannel = MethodChannel(
    'com.tf.flutter/native_router',
  );

  static bool get isConfigured => _configuration != null;

  static String get scheme => _configuration?.scheme ?? 'tffanclub';

  /// 应用启动时调用一次（建议在 [runApp] 前）。
  static void configure(WysRouteConfiguration configuration) {
    _configuration = configuration;
    _nativeRouteChannel.setMethodCallHandler(_handleNativeRouteCall);
    _routes.clear();
    _globalInterceptors
      ..clear()
      ..addAll(configuration.globalInterceptors);
    for (final route in configuration.routes) {
      registerRoute(route);
    }
    _registerBuiltInCapabilityRoutes();
  }

  static void registerRoute(WysRoute route) {
    final key = _routeKey(route.pattern);
    _routes[key] = route;
  }

  /// 注册 Flutter 页面：pattern → 固定 GetX path。
  static void registerPath(
    String pattern,
    String getPath, {
    WysRouteInterceptor? interceptor,
  }) {
    registerRoute(
      WysRoute(
        pattern: pattern,
        getPath: (_, __) => getPath,
        interceptor: interceptor,
      ),
    );
  }

  /// 注册方法路由（不打开页面）。
  static void registerHandler(
    String pattern,
    WysRouteHandler handler, {
    WysRouteInterceptor? interceptor,
  }) {
    registerRoute(
      WysRoute(
        pattern: pattern,
        targetType: WysRouteTargetType.handler,
        handler: handler,
        interceptor: interceptor,
      ),
    );
  }

  static void addInterceptor(WysRouteInterceptor interceptor) {
    _globalInterceptors.add(interceptor);
  }

  /// 注册 Flutter 路由对应的原生页面路径。
  ///
  /// 注册后调用 [routeURL] 时会优先打开原生页面，不再进入同名 Flutter 页面。
  static void registerNativeRoute(
    String flutterRoute, {
    String? androidPath,
    String? iosPath,
    String? ohosPath,
  }) {
    WysNativeRouteRegistry.register(
      flutterRoute,
      androidPath: androidPath,
      iosPath: iosPath,
      ohosPath: ohosPath,
    );
  }

  /// 批量注册 Flutter 路由与各平台原生页面路径。
  static void registerNativeRoutes(Map<String, WysNativeRoutePaths> routes) {
    WysNativeRouteRegistry.registerAll(routes);
  }

  /// 是否已注册（path、pageName 或完整 URL）。
  static bool canRoute(String urlOrPath) {

    if (WysNativePageNameMap.pathForUrlOrPageName(urlOrPath) != null) {
       return true;
    }

    if (WysNativeRouteRegistry.nativePathFor(urlOrPath) != null) {
      return true;
    }

    if (_resolveRoute(urlOrPath) != null) return true;
    return _resolvePathOnly(urlOrPath) != null;
  }

  /// 打开 URL / path / 原生 pageName。
  static Future<dynamic> routeURL(
    String urlOrPath, {
    Map<String, dynamic>? arguments,
  }) {
    final args = WysUrlUtils.mergeArguments(urlOrPath, extra: arguments);
    if (!_runInterceptors(urlOrPath, args)) {
      return Future.value(null);
    }

    final nativePath = WysNativeRouteRegistry.nativePathFor(urlOrPath);
    if (nativePath != null) {
      return _openNativeRoute(nativePath, args);
    }

    final path = _resolveNavigationPath(urlOrPath, args);
    if (path != null) {
      return _toNamed(path, arguments: args);
    }

    return _openUnknown(urlOrPath, args);
  }

  /// 强制打开 Flutter 页面，跳过原生路由注册表。
  ///
  /// 供 Android、iOS、鸿蒙原生侧通过 `openFlutterRoute` 通道回调使用，
  /// 避免已注册为原生目标的同名路由再次跳回原生页面。
  static Future<dynamic> openFlutterRoute(
    String urlOrPath, {
    Map<String, dynamic>? arguments,
  }) {
    final args = WysUrlUtils.mergeArguments(urlOrPath, extra: arguments);
    if (!_runInterceptors(urlOrPath, args)) {
      return Future.value(null);
    }

    final path = _resolveNavigationPath(urlOrPath, args);
    if (path != null) {
      return _toNamed(path, arguments: args);
    }
    return _openUnknown(urlOrPath, args);
  }

  /// 清空栈并打开（如开屏 → Tab），path 解析规则同 [routeURL]。
  static Future<dynamic> offAllNamed(
    String urlOrPath, {
    Map<String, dynamic>? arguments,
  }) {
    final args = WysUrlUtils.mergeArguments(urlOrPath, extra: arguments);
    if (!_runInterceptors(urlOrPath, args)) {
      return Future.value(null);
    }

    final path = _resolveNavigationPath(urlOrPath, args);
    if (path == null) {
      return _openUnknown(urlOrPath, args);
    }
    final future = Get.offAllNamed<dynamic>(path, arguments: args);
    if (future == null) {
      return Future<dynamic>.value(null);
    }
    return future;
  }

  static Future<dynamic> pushPage(
    String pageName, {
    Map<String, dynamic>? arguments,
    bool withContainer = false,
    bool opaque = true,
    bool secure = false,
  }) {
    final extra = <String, dynamic>{
      if (arguments != null) ...arguments,
      if (secure) 'secure': true,
      if (withContainer) 'withContainer': withContainer,
      if (!opaque) 'opaque': opaque,
    };
    return routeURL(pageName, arguments: extra);
  }

  /// 打开 H5 页面。
  ///
  /// 壳工程注册 [WysCapabilityRoutes.h5] 对应 WebView 页后，默认走应用内 H5。
  /// [external] = true 时可显式走系统浏览器兜底。
  static Future<dynamic> openH5(
    String url, {
    String? title,
    bool external = false,
    Map<String, dynamic>? arguments,
  }) {
    final target = url.trim();
    if (target.isEmpty) return Future<dynamic>.value(null);
    final args = <String, dynamic>{
      if (arguments != null) ...arguments,
      'url': target,
      if (title != null && title.isNotEmpty) 'title': title,
    };
    if (external) {
      return _launchExternalUrl(target);
    }
    return routeURL(WysCapabilityRoutes.h5, arguments: args);
  }

  static Future<dynamic> openSystemWeb(String url) {
    final target = url.trim();
    if (target.isEmpty) return Future<dynamic>.value(null);
    return _launchExternalUrl(target);
  }

  static void pop<T>([T? result]) {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<T>(result: result);
    }
  }

  static Map<String, dynamic>? currentArguments() {
    return Get.arguments as Map<String, dynamic>?;
  }

  /// 当前 GetX 路由 path（与 [RoutePath] 一致）。
  static String get currentRoute => Get.currentRoute;

  static String? _resolveNavigationPath(
    String urlOrPath,
    Map<String, dynamic> args,
  ) {
    final pageNamePath = WysNativePageNameMap.pathForUrlOrPageName(urlOrPath);
    if (pageNamePath != null) {
      return pageNamePath;
    }

    final route = _resolveRoute(urlOrPath);
    if (route != null) {
      if (route.interceptor != null && !route.interceptor!(urlOrPath, args)) {
        return null;
      }
      if (route.targetType == WysRouteTargetType.handler &&
          route.handler != null) {
        route.handler!(urlOrPath, args);
        return null;
      }
      final path = route.getPath?.call(urlOrPath, args);
      if (path != null && path.isNotEmpty) {
        return path;
      }
    }

    return _resolvePathOnly(urlOrPath);
  }

  static String _routeKey(String pattern) {
    final path = WysUrlUtils.standardPath(pattern);
    if (path.isNotEmpty) return path;
    return pattern.trim();
  }

  static WysRoute? _resolveRoute(String urlOrPath) {
    final path = WysUrlUtils.standardPath(urlOrPath);
    if (path.isNotEmpty && _routes.containsKey(path)) {
      return _routes[path];
    }
    final trimmed = urlOrPath.trim();
    return _routes[trimmed];
  }

  static String? _resolvePathOnly(String urlOrPath) {
    final path = WysUrlUtils.standardPath(urlOrPath);
    if (path.isEmpty) return null;
    if (Get.routeTree.routes.any((r) => r.name == path)) {
      return path;
    }
    return null;
  }

  static bool _runInterceptors(
    String urlOrPath,
    Map<String, dynamic> arguments,
  ) {
    for (final interceptor in _globalInterceptors) {
      if (!interceptor(urlOrPath, arguments)) {
        return false;
      }
    }
    return true;
  }

  static Future<dynamic> _openUnknown(
    String urlOrPath,
    Map<String, dynamic> arguments,
  ) {
    final custom = _configuration?.onUnknownRoute;
    if (custom != null) {
      return custom(urlOrPath, arguments);
    }
    final pending = _configuration?.pendingRoute ?? '/pending';
    return _toNamed(
      pending,
      arguments: <String, dynamic>{'pageName': urlOrPath, ...arguments},
    );
  }

  static Future<dynamic> _openNativeRoute(
    String nativePath,
    Map<String, dynamic> arguments,
  ) {
    return _nativeRouteChannel.invokeMethod<dynamic>('openNativeRoute', {
      'path': nativePath,
      'arguments': arguments,
    });
  }

  static Future<dynamic> _handleNativeRouteCall(MethodCall call) {
    if (call.method != 'openFlutterRoute') {
      throw MissingPluginException('未实现原生路由方法：${call.method}');
    }
    final payload = _stringDynamicMap(call.arguments);
    final route = payload['route']?.toString().trim() ?? '';
    if (route.isEmpty) {
      throw PlatformException(
        code: 'INVALID_FLUTTER_ROUTE',
        message: 'Flutter 路由不能为空',
      );
    }
    return openFlutterRoute(
      route,
      arguments: _stringDynamicMap(payload['arguments']),
    );
  }

  static Map<String, dynamic> _stringDynamicMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  /// GetX [Get.toNamed] 返回 `Future<T?>?`，统一为 `Future<dynamic>`。
  static Future<dynamic> _toNamed(
    String route, {
    Map<String, dynamic>? arguments,
  }) {
    final future = Get.toNamed<dynamic>(route, arguments: arguments);
    if (future == null) {
      return Future<dynamic>.value(null);
    }
    return future;
  }

  static void _registerBuiltInCapabilityRoutes() {
    registerHandler(WysCapabilityRoutes.redirect, (url, args) {
      final target =
          args['redirect_url']?.toString() ?? args['url']?.toString() ?? '';
      if (target.isEmpty) return;
      if (!_isAllowedRedirect(target)) {
        debugPrint('[WysRouter] redirect blocked: $target');
        return;
      }
      routeURL(
        target,
        arguments: Map<String, dynamic>.from(args)..remove('redirect_url'),
      );
    });

    registerHandler(WysCapabilityRoutes.web, (url, args) {
      debugPrint(
        '[WysRouter] /to/web — 请在壳工程注册 WebView 页并 registerPath: ${args['url']}',
      );
    });

    if (!_routes.containsKey(_routeKey(WysCapabilityRoutes.h5))) {
      registerHandler(WysCapabilityRoutes.h5, (url, args) {
        final raw = args['url']?.toString() ?? '';
        if (raw.isEmpty) return;
        final title = args['title']?.toString() ?? '';
        debugPrint('[WysRouter] /to/h5 fallback external: $title $raw');
        _launchExternalUrl(raw);
      });
    }

    registerHandler(WysCapabilityRoutes.flutter, (url, args) {
      final inner = args['url']?.toString() ?? '';
      if (inner.isEmpty) return;
      final params = _decodeParams(args['params']);
      routeURL(inner, arguments: params);
    });

    registerHandler(WysCapabilityRoutes.systemWeb, (url, args) {
      final raw = args['url']?.toString() ?? '';
      if (raw.isEmpty) return;
      _launchExternalUrl(raw);
    });
  }

  static Future<void> _launchExternalUrl(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static bool _isAllowedRedirect(String target) {
    final uri = Uri.tryParse(target);
    if (uri == null) return false;
    if (uri.scheme.isEmpty || uri.scheme == scheme) return true;
    // 本项目深链 scheme + 历史兼容
    if (uri.scheme == 'xiaomao' ||
        uri.scheme == 'tfapp' ||
        uri.scheme == 'tffanclub') {
      return true;
    }
    if (uri.path.startsWith('/')) return true;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  static Map<String, dynamic> _decodeParams(Object? params) {
    if (params == null) return {};
    if (params is Map) {
      return Map<String, dynamic>.from(params);
    }
    final s = params.toString();
    if (s.isEmpty) return {};
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {'params': s};
  }
}
