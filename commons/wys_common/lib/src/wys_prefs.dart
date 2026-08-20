import 'package:shared_preferences/shared_preferences.dart';

/// 本地键值存储（基于 [SharedPreferences]）。
abstract final class WysPrefs {
  WysPrefs._();

  static Future<SharedPreferences> get _sp => SharedPreferences.getInstance();

  static Future<void> save(String key, Object? value) async {
    final sp = await _sp;
    if (value == null) {
      await sp.remove(key);
      return;
    }
    switch (value) {
      case double v:
        await sp.setDouble(key, v);
      case int v:
        await sp.setInt(key, v);
      case bool v:
        await sp.setBool(key, v);
      case String v:
        await sp.setString(key, v);
      case List<String> v:
        await sp.setStringList(key, v);
      default:
        await sp.setString(key, value.toString());
    }
  }

  static Future<double> getDouble(String key, {double defaultValue = 0}) async {
    return (await _sp).getDouble(key) ?? defaultValue;
  }

  static Future<String> getString(String key, {String defaultValue = ''}) async {
    return (await _sp).getString(key) ?? defaultValue;
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    return (await _sp).getInt(key) ?? defaultValue;
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return (await _sp).getBool(key) ?? defaultValue;
  }

  static Future<List<String>?> getStringList(String key) async {
    return (await _sp).getStringList(key);
  }

  static Future<bool> remove(String key) async {
    return (await _sp).remove(key);
  }

  static Future<void> clear() async {
    await (await _sp).clear();
  }
}

/// 兼容旧 [WysUtils] API。
@Deprecated('Use WysPrefs')
abstract final class WysUtils {
  WysUtils._();

  static Future<void> saveData(String key, dynamic value) =>
      WysPrefs.save(key, value);

  static Future<double> getDataDouble(String key) => WysPrefs.getDouble(key);

  static Future<String> getDataString(String key) => WysPrefs.getString(key);

  static Future<int> getDataInt(String key) => WysPrefs.getInt(key);

  static Future<bool> getDataBool(String key) => WysPrefs.getBool(key);

  static Future<List<String>?> getDataListString(String key) =>
      WysPrefs.getStringList(key);

  static Future<bool> remove(String key) => WysPrefs.remove(key);

  static Future<void> clearAll() => WysPrefs.clear();
}