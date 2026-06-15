import 'package:get/get.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';

/// 模块独立运行时使用，不持久化。
class DefaultEnvironmentService extends EnvironmentService {
  @override
  final Rx<AppEnv> currentEnv = AppEnv.test.obs;

  @override
  Future<void> setEnv(AppEnv env) async {
    if (currentEnv.value == env) return;
    currentEnv.value = env;
    await onEnvChanged?.call(env);
  }
}
