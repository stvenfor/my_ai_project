import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_settings/env/environment_service_impl.dart';

/// 环境模块会话入口：注册全局 [EnvironmentService]。
class EnvironmentSession {
  EnvironmentSession._();

  static Future<EnvironmentService> register({bool permanent = true}) async {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>();
    }
    await Get.putAsync<EnvironmentService>(
      EnvironmentServiceImpl.create,
      permanent: permanent,
    );
    return Get.find<EnvironmentService>();
  }
}
