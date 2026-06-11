import 'dart:convert';

import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 登录会话本地实现：登录写入 SP，登出清除。
class UserServiceImpl extends UserService {
  UserServiceImpl(this._prefs);

  static const storageKey = 'auth_user_session';

  final SharedPreferences _prefs;

  @override
  final Rxn<User> currentUser = Rxn<User>();

  static Future<UserServiceImpl> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = UserServiceImpl(prefs);
    service._restoreFromStorage();
    return service;
  }

  void _restoreFromStorage() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      currentUser.value = User.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      currentUser.value = null;
    }
  }

  @override
  Future<void> setUser(User user) async {
    currentUser.value = user;
    await _prefs.setString(storageKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    currentUser.value = null;
    await _prefs.remove(storageKey);
  }
}
