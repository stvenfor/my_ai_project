import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';

class SettingsViewModel extends GetxController {
  AppConfigController? get config {
    if (!Get.isRegistered<AppConfigController>()) return null;
    return Get.find<AppConfigController>();
  }

  EnvironmentService? get envService {
    if (!Get.isRegistered<EnvironmentService>()) return null;
    return Get.find<EnvironmentService>();
  }

  Future<void> toggleTheme() async => config?.toggleTheme();

  Future<void> setImmersive(bool value) async => config?.setImmersive(value);

  Future<void> setLocale(Locale locale) async => config?.setLocale(locale);

  Future<void> setEnvironment(AppEnv env) async {
    final service = envService;
    if (service == null) return;
    await service.setEnv(env);
    Get.snackbar(
      '环境已切换',
      '当前：${service.config.label} · ${service.baseUrl}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
