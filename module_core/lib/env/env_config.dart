import 'package:module_core/env/app_env.dart';

/// 各环境 endpoint 配置（按项目替换预发/线上域名）。
class EnvConfig {
  const EnvConfig({
    required this.env,
    required this.baseUrl,
    required this.label,
  });

  final AppEnv env;
  final String baseUrl;
  final String label;

  static const configs = {
    AppEnv.test: EnvConfig(
      env: AppEnv.test,
      baseUrl: 'https://www.wanandroid.com/',
      label: '测试',
    ),
    AppEnv.staging: EnvConfig(
      env: AppEnv.staging,
      // TODO: 替换为预发域名
      baseUrl: 'https://www.wanandroid.com/',
      label: '预发',
    ),
    AppEnv.production: EnvConfig(
      env: AppEnv.production,
      // TODO: 替换为线上域名
      baseUrl: 'https://www.wanandroid.com/',
      label: '线上',
    ),
  };

  static EnvConfig of(AppEnv env) => configs[env]!;
}
