import 'package:wys_network/wys_network.dart';

/// 极光推送配置，跟随当前网络环境。
///
/// AppKey 占位：控制台建应用后替换；含 `PLACEHOLDER` 时 [isConfigured] 为 false。
class PushConfig {
  PushConfig._();

  static const String iosChannel = 'App Store';
  static const String defaultChannel = 'developer-default';

  /// 测试 / 开发环境 AppKey（占位）。
  static const String testAppKey = 'DEV_JPUSH_APP_KEY_PLACEHOLDER';

  /// 正式环境 AppKey（占位）。
  static const String productionAppKey = 'PROD_JPUSH_APP_KEY_PLACEHOLDER';

  /// 仅 product 使用正式极光环境；dev/test/custom 均使用测试环境。
  /// AppEnvironment 未初始化时按非生产处理（避免启动早期 LateInitializationError）。
  static bool get isProduction =>
      AppEnvironment.isInitialized &&
      AppEnvironment.instance.netEnvironment == WysNetEnvironment.product;

  /// 获取当前环境的 AppKey。
  static String get appKey => isProduction ? productionAppKey : testAppKey;

  /// 是否已填真实 AppKey（非空且非 PLACEHOLDER）。
  static bool get isConfigured {
    final key = appKey.trim();
    if (key.isEmpty) return false;
    return !key.toUpperCase().contains('PLACEHOLDER');
  }
}
