import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_global_cache/module_global_cache.dart';

class AppController extends GetxController implements AppConfigController {
  final _themeMode = ThemeMode.system.obs;
  final _locale = const Locale('zh').obs;
  final _immersiveMode = true.obs;

  ThemeMode get themeMode => _themeMode.value;
  Locale get locale => _locale.value;
  bool get immersiveMode => _immersiveMode.value;

  Rx<ThemeMode> get themeModeRx => _themeMode;
  Rx<Locale> get localeRx => _locale;
  RxBool get immersiveModeRx => _immersiveMode;

  Future<void> loadSettings() async {
    final settings = SpManager.instance.loadAppSettings();
    _themeMode.value = _parseThemeMode(settings.themeMode);
    _locale.value = Locale(
      settings.languageCode,
      settings.countryCode,
    );
    _immersiveMode.value = settings.immersiveMode;
    await _applySystemUi();
  }

  @override
  Future<void> toggleTheme() async {
    final next = switch (_themeMode.value) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
    await setThemeMode(next);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await _persist();
    await _applySystemUi();
  }

  @override
  Future<void> setLocale(Locale value) async {
    _locale.value = value;
    Get.updateLocale(value);
    await _persist();
  }

  @override
  Future<void> toggleImmersive() async {
    _immersiveMode.value = !_immersiveMode.value;
    await _persist();
    await _applySystemUi();
  }

  @override
  Future<void> setImmersive(bool enabled) async {
    _immersiveMode.value = enabled;
    await _persist();
    await _applySystemUi();
  }

  Brightness resolveBrightness(BuildContext context) {
    return switch (_themeMode.value) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  Future<void> _applySystemUi() async {
    final brightness = switch (_themeMode.value) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    await ImmersiveHelper.apply(
      brightness: brightness,
      immersive: _immersiveMode.value,
    );
  }

  Future<void> _persist() async {
    await SpManager.instance.saveAppSettings(
      AppSettings(
        themeMode: _themeMode.value.name,
        languageCode: _locale.value.languageCode,
        countryCode: _locale.value.countryCode,
        immersiveMode: _immersiveMode.value,
      ),
    );
  }

  ThemeMode _parseThemeMode(String raw) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }
}
