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
  /// Go 后端 my_go_study 地址。
  /// - 本机 / iOS 模拟器：127.0.0.1
  /// - Android 模拟器：自动映射为 10.0.2.2
  /// - 鸿蒙/真机：`flutter run --dart-define=BACKEND_HOST=192.168.x.x`
  /// - 局域网联调：`flutter run --dart-define-from-file=.env.lan`（见 `.env.lan.example`）
  final String backendBaseUrl;
  final String wsBaseUrl;
  final String rongAppKey;
  final String label;

  /// `--dart-define=RONG_APP_KEY=...` 优先，否则用环境默认占位。
  static String _rongKey(String fallback) {
    const fromDefine = String.fromEnvironment('RONG_APP_KEY', defaultValue: '');
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
    return fallback;
  }

  static final configs = {
    AppEnv.test: EnvConfig(
      env: AppEnv.test,
      backendBaseUrl: 'http://127.0.0.1:8080',
      wsBaseUrl: 'ws://127.0.0.1:8080/realtime/v1/connect',
      rongAppKey: _rongKey('DEV_RONG_APP_KEY_PLACEHOLDER'),
      label: '测试',
    ),
    AppEnv.staging: EnvConfig(
      env: AppEnv.staging,
      backendBaseUrl: 'http://127.0.0.1:8080',
      wsBaseUrl: 'ws://127.0.0.1:8080/realtime/v1/connect',
      rongAppKey: _rongKey('DEV_RONG_APP_KEY_PLACEHOLDER'),
      label: '预发',
    ),
    AppEnv.production: EnvConfig(
      env: AppEnv.production,
      backendBaseUrl: 'https://api.xiaomaomain.com',
      wsBaseUrl: 'wss://ws.xiaomaomain.com/realtime/v1/connect',
      rongAppKey: _rongKey('PROD_RONG_APP_KEY_PLACEHOLDER'),
      label: '线上',
    ),
  };

  static EnvConfig of(AppEnv env) => configs[env]!;
}
