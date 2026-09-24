import 'package:flutter/widgets.dart';

/// 统一收起软键盘：提交按钮、路由切换、主 Tab 切换、点空白区域。
class AppKeyboard {
  AppKeyboard._();

  /// 注册到 [NavigatorObserver]，push/pop/replace 时自动收起。
  static final NavigatorObserver navigatorObserver =
      _KeyboardDismissNavigatorObserver();

  static void dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 点按收起键盘。用 [Listener] 只观察指针，不进手势竞技场，
  /// 避免抢走子组件（语音气泡、列表项等）的 onTap。
  static Widget dismissOnTap({Key? key, required Widget child}) {
    return Listener(
      key: key,
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => dismiss(),
      child: child,
    );
  }
}

class _KeyboardDismissNavigatorObserver extends NavigatorObserver {
  void _dismiss() => AppKeyboard.dismiss();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dismiss();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dismiss();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _dismiss();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dismiss();
}
