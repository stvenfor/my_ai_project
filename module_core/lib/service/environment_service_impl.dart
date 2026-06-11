import 'package:get/get.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 仅在壳工程注册，不通过 [module_core/core.dart] 导出。
class EnvironmentServiceImpl extends EnvironmentService {
  EnvironmentServiceImpl(this._prefs);

  static const storageKey = 'core_app_env';

  final SharedPreferences _prefs;

  @override
  final Rx<AppEnv> currentEnv = AppEnv.test.obs;

  static Future<EnvironmentServiceImpl> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = EnvironmentServiceImpl(prefs);
    service._restoreFromStorage();
    return service;
  }

  void _restoreFromStorage() {
    currentEnv.value = AppEnv.fromKey(_prefs.getString(storageKey));
  }

  @override
  Future<void> setEnv(AppEnv env) async {
    if (currentEnv.value == env) return;
    currentEnv.value = env;
    await _prefs.setString(storageKey, env.name);
    await onEnvChanged?.call(env);
  }
}
