import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 轻量封装。
class SpUtils {
  SpUtils._();

  static SharedPreferences? _prefs;

  static bool get isInitialized => _prefs != null;

  /// 供其他模块（如 module_global_cache）复用同一 SP 实例。
  static SharedPreferences get sharedPreferences {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('SpUtils 未初始化，请先调用 ModuleUtilsInitializer.initialize()');
    }
    return prefs;
  }

  /// 初始化，建议在 [ModuleUtilsInitializer.initialize] 中调用。
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('SpUtils 未初始化，请先调用 ModuleUtilsInitializer.initialize()');
    }
    return prefs;
  }

  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static String? getString(String key, {String? defaultValue}) =>
      _instance.getString(key) ?? defaultValue;

  static Future<bool> setBool(String key, bool value) =>
      _instance.setBool(key, value);

  static bool getBool(String key, {bool defaultValue = false}) =>
      _instance.getBool(key) ?? defaultValue;

  static Future<bool> setInt(String key, int value) =>
      _instance.setInt(key, value);

  static int getInt(String key, {int defaultValue = 0}) =>
      _instance.getInt(key) ?? defaultValue;

  static Future<bool> setDouble(String key, double value) =>
      _instance.setDouble(key, value);

  static double getDouble(String key, {double defaultValue = 0}) =>
      _instance.getDouble(key) ?? defaultValue;

  static Future<bool> setStringList(String key, List<String> value) =>
      _instance.setStringList(key, value);

  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) =>
      _instance.getStringList(key) ?? defaultValue;

  /// 存储 JSON 对象。
  static Future<bool> setJson(String key, Map<String, dynamic> value) {
    return setString(key, jsonEncode(value));
  }

  /// 读取 JSON 对象。
  static Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> remove(String key) => _instance.remove(key);

  static Future<bool> clear() => _instance.clear();

  static bool containsKey(String key) => _instance.containsKey(key);

  static Set<String> get keys => _instance.getKeys();
}
