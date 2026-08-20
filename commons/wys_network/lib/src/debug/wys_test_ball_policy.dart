import 'package:flutter/foundation.dart';

import '../app_environment.dart';

/// 何时显示环境浮窗（对齐 iOS `PRODUCTING_ENV` / `+[TFTestBall startTest]`）。
abstract final class WysTestBallPolicy {
  /// 正式编译宏 `TF_NET_PRODUCT` → 不显示（对齐 `TF_NET_PRODUCT` / 生产包）。
  static bool get show {
    const productMacro = bool.fromEnvironment('TF_NET_PRODUCT');
    if (productMacro) return false;

    const forceHide = bool.fromEnvironment('TF_HIDE_TEST_BALL');
    if (forceHide) return false;

    const forceShow = bool.fromEnvironment('TF_SHOW_TEST_BALL');
    if (forceShow) return true;

    // 与 iOS 测试包一致：非生产宏时显示（开发 / 测试包）。
    if (kDebugMode) return true;

    // Profile / 非 PRODUCT 的 release 仍可显式打开
    return AppEnvironment.instance.netEnvironment != WysNetEnvironment.product;
  }
}