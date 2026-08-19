import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_utils/module_utils.dart';

/// 环境服务实现：持久化当前 App 环境（测试/预发/线上）。
class EnvironmentServiceImpl extends EnvironmentService {
  EnvironmentServiceImpl();

  static const storageKey = 'core_app_env';

  @override
  final Rx<AppEnv> currentEnv = AppEnv.test.obs;

  static Future<EnvironmentServiceImpl> create() async {
    final service = EnvironmentServiceImpl();
    service._restoreFromStorage();
    return service;
  }

  void _restoreFromStorage() {
    currentEnv.value = AppEnv.fromKey(SpUtils.getString(storageKey));
  }

  @override
  Future<void> setEnv(AppEnv env) async {
    if (currentEnv.value == env) return;
    currentEnv.value = env;
    await SpUtils.setString(storageKey, env.name);
    await onEnvChanged?.call(env);
  }
}
