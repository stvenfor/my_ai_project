import 'package:module_core/env/app_env.dart';

/// 各环境 endpoint 配置（按项目替换预发/线上域名）。
class EnvConfig {
  const EnvConfig({
    required this.env,
    required this.backendBaseUrl,
    required this.wsBaseUrl,
    required this.rongAppKey,
    required this.label,
  });

  final AppEnv env;
  /// Go 后端 my_go_study 地址；Android 模拟器请改为 http://10.0.2.2:8080
  final String backendBaseUrl;
  final String wsBaseUrl;
  final String rongAppKey;
  final String label;

  static const configs = {
    AppEnv.test: EnvConfig(
      env: AppEnv.test,
      backendBaseUrl: 'http://127.0.0.1:8080',
      wsBaseUrl: 'wss://mock-ws.test.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'DEV_RONG_APP_KEY_PLACEHOLDER',
      label: '测试',
    ),
    AppEnv.staging: EnvConfig(
      env: AppEnv.staging,
      backendBaseUrl: 'http://127.0.0.1:8080',
      wsBaseUrl: 'wss://mock-ws.staging.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'DEV_RONG_APP_KEY_PLACEHOLDER',
      label: '预发',
    ),
    AppEnv.production: EnvConfig(
      env: AppEnv.production,
      backendBaseUrl: 'https://api.xiaomaomain.com',
      wsBaseUrl: 'wss://ws.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: 'PROD_RONG_APP_KEY_PLACEHOLDER',
      label: '线上',
    ),
  };

  static EnvConfig of(AppEnv env) => configs[env]!;
}
