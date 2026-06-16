/// 登录成功后回跳目标路由（一次性消费）。
class LoginRedirect {
  LoginRedirect._();

  static String? _pendingRoute;

  static void setPending(String route) {
    _pendingRoute = route;
  }

  static String? peek() => _pendingRoute;

  static String? takePending() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  static void clear() => _pendingRoute = null;
}
