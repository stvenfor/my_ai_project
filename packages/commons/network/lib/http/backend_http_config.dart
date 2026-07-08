import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// 解析 Go 后端 baseUrl，独立于 WanAndroid demo API。
class BackendHttpConfig {
  BackendHttpConfig._();

  static String resolveBackendBaseUrl() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().backendBaseUrl;
    }
    return EnvConfig.of(AppEnv.test).backendBaseUrl;
  }
}
