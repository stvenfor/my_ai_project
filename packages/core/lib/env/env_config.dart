import 'package:module_core/env/app_env.dart';

/// 各环境 endpoint 配置（按项目替换预发/线上域名）。
class EnvConfig {
  const EnvConfig({
    required this.env,
    required this.baseUrl,
    required this.wsBaseUrl,
    required this.rongAppKey,
    required this.label,
  });

  final AppEnv env;
  final String baseUrl;
  final String wsBaseUrl;
  final String rongAppKey;
  final String label;

  static const configs = {
    AppEnv.test: EnvConfig(
      env: AppEnv.test,
      baseUrl: 'https://www.wanandroid.com/',
      wsBaseUrl: 'wss://mock-ws.test.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'DEV_RONG_APP_KEY_PLACEHOLDER',
      label: '测试',
    ),
    AppEnv.staging: EnvConfig(
      env: AppEnv.staging,
      baseUrl: 'https://www.wanandroid.com/',
      wsBaseUrl: 'wss://mock-ws.staging.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'DEV_RONG_APP_KEY_PLACEHOLDER',
      label: '预发',
    ),
    AppEnv.production: EnvConfig(
      env: AppEnv.production,
      baseUrl: 'https://www.wanandroid.com/',
      wsBaseUrl: 'wss://ws.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'PROD_RONG_APP_KEY_PLACEHOLDER',
      label: '线上',
    ),
  };

  static EnvConfig of(AppEnv env) => configs[env]!;
}
