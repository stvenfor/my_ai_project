import 'package:flutter/material.dart';

/// 供 [MaterialApp.builder] 外层组件弹窗（悬浮球等）使用。
///
/// 主工程：`WysAppNavigator.navigatorKey = Get.key`（GetX）或自建 [GlobalKey]。
abstract final class WysAppNavigator {
  static GlobalKey<NavigatorState>? navigatorKey;

  static BuildContext? get overlayContext {
    final state = navigatorKey?.currentState;
    final ctx = state?.overlay?.context ?? state?.context;
    if (ctx != null && ctx.mounted) return ctx;
    return null;
  }
}