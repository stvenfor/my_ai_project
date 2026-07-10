import 'dart:convert';

import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// 登录会话本地实现：登录写入 SP，登出清除。
class UserServiceImpl extends UserService {
  UserServiceImpl();

  static const storageKey = 'auth_user_session';

  @override
  final Rxn<User> currentUser = Rxn<User>();

  static Future<UserServiceImpl> create() async {
    final service = UserServiceImpl();
    service._restoreFromStorage();
    return service;
  }

  void _restoreFromStorage() {
    final raw = SpUtils.getString(storageKey);
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
    await SpUtils.setString(storageKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    currentUser.value = null;
    await SpUtils.remove(storageKey);
  }

  @override
  Future<void> updateAuthTokens({
    required String token,
    required String refreshToken,
    String? sessionId,
  }) async {
    final user = currentUser.value;
    if (user == null) return;
    await setUser(
      user.copyWith(
        token: token,
        refreshToken: refreshToken,
        sessionId: sessionId?.isNotEmpty == true ? sessionId : user.sessionId,
      ),
    );
  }
}
