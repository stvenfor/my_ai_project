import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account_user.dart';

/// 本地持久化登录态（token + 用户信息）。
class AccountSessionStore {
  AccountSessionStore(this._prefs);

  static const _keyUserJson = 'wys_account_user_json';

  final SharedPreferences _prefs;

  /// iOS 偶发 Pigeon 通道未就绪时重试；仍失败则抛出。
  static Future<AccountSessionStore> create() async {
    const attempts = 5;
    Object? lastError;
    for (var i = 0; i < attempts; i++) {
      try {
        final prefs = await SharedPreferences.getInstance();
        return AccountSessionStore(prefs);
      } on PlatformException catch (e, s) {
        lastError = e;
        debugPrint('wys_account: SharedPreferences attempt ${i + 1}/$attempts: $e');
        if (i < attempts - 1) {
          await Future<void>.delayed(Duration(milliseconds: 80 * (i + 1)));
        } else {
          Error.throwWithStackTrace(e, s);
        }
      }
    }
    throw StateError('SharedPreferences unavailable: $lastError');
  }

  AccountUser? readUser() {
    final raw = _prefs.getString(_keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AccountUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUser(AccountUser? user) async {
    if (user == null || !user.hasValidToken) {
      await _prefs.remove(_keyUserJson);
      return;
    }
    await _prefs.setString(_keyUserJson, jsonEncode(user.toJson()));
  }

  /// 清除本地登录态。
  ///
  /// OHOS 上 `remove` 可能存在异步刷盘延迟：如果 App 在 `remove` 返回后
  /// 立即被杀死，磁盘上可能仍残留旧数据。先 `setString('')` 覆盖旧值
  /// 确保 `readUser()` 返回 null，再 `remove` 正式删除 key。
  Future<void> clear() async {
    await _prefs.setString(_keyUserJson, '');
    await _prefs.remove(_keyUserJson);
    debugPrint('[AccountSessionStore] clear: key=$_keyUserJson removed');
  }
}