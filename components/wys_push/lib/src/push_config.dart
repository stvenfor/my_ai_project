import 'package:wys_network/wys_network.dart';

/// 极光推送配置，跟随当前网络环境。
class PushConfig {
  PushConfig._();

  /// 测试环境 AppKey
  static const String testAppKey = '11a0ffe89abbde2be74043f4';

  /// 正式环境 AppKey
  static const String productionAppKey = 'd393c17a7cb3af79e6d56371';

  /// 仅 product 使用正式极光环境；dev/test/custom 均使用测试环境。
  static bool get isProduction =>
      AppEnvironment.instance.netEnvironment == WysNetEnvironment.product;

  /// 获取当前环境的 AppKey
  static String get appKey => isProduction ? productionAppKey : testAppKey;
}
