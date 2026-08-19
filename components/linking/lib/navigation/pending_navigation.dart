import 'package:module_linking/models/app_route_intent.dart';

/// 冷启动 / 登录拦截期间暂存的路由意图。
class PendingNavigation {
  PendingNavigation._();

  static AppRouteIntent? _pending;

  static bool get hasPending => _pending != null;

  static void set(AppRouteIntent intent) {
    _pending = intent;
  }

  static AppRouteIntent? peek() => _pending;

  static AppRouteIntent? take() {
    final value = _pending;
    _pending = null;
    return value;
  }

  static void clear() => _pending = null;
}
