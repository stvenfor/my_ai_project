import 'package:flutter/material.dart';

abstract class AppConfigController {
  ThemeMode get themeMode;
  Locale get locale;
  bool get immersiveMode;

  Future<void> toggleTheme();
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setLocale(Locale locale);
  Future<void> toggleImmersive();
  Future<void> setImmersive(bool enabled);
}
