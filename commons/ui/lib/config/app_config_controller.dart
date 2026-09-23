import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class AppConfigController {
  ThemeMode get themeMode;
  Rx<ThemeMode> get themeModeRx;
  Locale get locale;
  bool get immersiveMode;

  Future<void> toggleTheme();
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setLocale(Locale locale);
  Future<void> toggleImmersive();
  Future<void> setImmersive(bool enabled);
}
