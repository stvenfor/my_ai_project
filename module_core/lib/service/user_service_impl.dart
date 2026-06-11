import 'dart:convert';

import 'package:get/get.dart';
import 'package:module_core/model/user.dart';
import 'package:module_core/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 仅在壳工程注册，不通过 [module_core/core.dart] 导出。
class UserServiceImpl extends UserService {
  UserServiceImpl(this._prefs);

  static const storageKey = 'core_current_user';

  final SharedPreferences _prefs;

  @override
  final Rxn<User> currentUser = Rxn<User>();

  /// 异步工厂：恢复持久化用户后再注册到 GetX。
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
