import '../app_environment.dart';

/// 何时显示环境浮窗（对齐 iOS `PRODUCTING_ENV` / `+[TFTestBall startTest]`）。
/// 环境以编译宏为准，不用 Flutter debug/release 包类型判断。
abstract final class WysTestBallPolicy {
  /// 正式编译宏 `TF_NET_PRODUCT` → 不显示。
  static bool get show {
    const productMacro = bool.fromEnvironment('TF_NET_PRODUCT');
    if (productMacro) return false;

    const forceHide = bool.fromEnvironment('TF_HIDE_TEST_BALL');
    if (forceHide) return false;

    const forceShow = bool.fromEnvironment('TF_SHOW_TEST_BALL');
    if (forceShow) return true;

    // 无正式宏时：非 product 网络环境可显示（profile/release 测试包亦可）。
    if (!AppEnvironment.isInitialized) return true;
    return AppEnvironment.instance.netEnvironment != WysNetEnvironment.product;
  }
}