import 'app_environment.dart';

/// 与 iOS `TFTestBall.m` + `ENVIRONMENT_NET` 完全一致。
abstract final class WysApiHosts {
  /// 开发 `ENVIRONMENT_NET_DEV`
  static const dev = 'http://tf.wohkn.cn';

  /// 测试（默认）`ENVIRONMENT_NET_TEST` / `appdev`
  static const test = 'https://appdev.tfent.cn';

  /// 正式 `ENVIRONMENT_NET_PRODUCT`
  static const product = 'https://app.tfent.cn';

  static String forEnv(AppEnv env) => switch (env) {
        AppEnv.debug => test,
        AppEnv.release => product,
      };
}