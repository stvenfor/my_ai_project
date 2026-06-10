import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';

class SettingsViewModel extends GetxController {
  AppConfigController? get config {
    if (!Get.isRegistered<AppConfigController>()) return null;
    return Get.find<AppConfigController>();
  }

  Future<void> toggleTheme() async => config?.toggleTheme();

  Future<void> setImmersive(bool value) async => config?.setImmersive(value);

  Future<void> setLocale(Locale locale) async => config?.setLocale(locale);
}
