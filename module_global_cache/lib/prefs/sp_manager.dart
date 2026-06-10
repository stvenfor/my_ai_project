import 'dart:convert';

import 'package:module_global_cache/model/app_settings.dart';
import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_utils/module_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpManager {
  SpManager._();

  static SpManager? _instance;
  static SharedPreferences? _prefs;

  static Future<SpManager> init() async {
    if (!SpUtils.isInitialized) {
      await ModuleUtilsInitializer.initialize();
    }
    _prefs = SpUtils.sharedPreferences;
    _instance ??= SpManager._();
    return _instance!;
  }

  static SpManager get instance {
    final manager = _instance;
    final prefs = _prefs;
    if (manager == null || prefs == null) {
      throw StateError('SpManager has not been initialized.');
    }
    return manager;
  }

  Future<void> setString(String key, String value) async {
    await _requirePrefs.setString(key, value);
  }

  String? getString(String key) => _requirePrefs.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _requirePrefs.setBool(key, value);
  }

  bool? getBool(String key) => _requirePrefs.getBool(key);

  Future<void> saveAppSettings(AppSettings settings) async {
    await setString(SpKeys.appSettings, jsonEncode(settings.toJson()));
  }

  AppSettings loadAppSettings() {
    final raw = getString(SpKeys.appSettings);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      return AppSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  SharedPreferences get _requirePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('SpManager has not been initialized.');
    }
    return prefs;
  }
}
