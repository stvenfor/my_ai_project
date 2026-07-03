import 'package:get/get.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_core/env/env_config.dart';

typedef EnvChangedHandler = Future<void> Function(AppEnv env);

/// 环境配置抽象服务，业务模块通过 [config.baseUrl] 读取当前 API 地址。
abstract class EnvironmentService extends GetxService {
  Rx<AppEnv> get currentEnv;

  EnvConfig get config => EnvConfig.of(currentEnv.value);

  String get baseUrl => config.baseUrl;

  String get wsBaseUrl => config.wsBaseUrl;

  String get rongAppKey => config.rongAppKey;

  /// 壳工程注册：环境切换后重建 Http 等基础设施。
  EnvChangedHandler? onEnvChanged;

  Future<void> setEnv(AppEnv env);
}
