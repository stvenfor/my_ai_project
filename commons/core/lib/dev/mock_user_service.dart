import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// 模块独立运行时使用，不持久化到 SharedPreferences。
class MockUserService extends UserService {
  MockUserService({User? initialUser}) {
    currentUser.value = initialUser ??
        const User(
          id: 'dev_user',
          name: '阳叔叔',
          avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=yang',
          token: 'dev_token',
        );
  }

  @override
  final Rxn<User> currentUser = Rxn<User>();

  @override
  Future<void> setUser(User user) async {
    currentUser.value = user;
  }

  @override
  Future<void> clearUser() async {
    currentUser.value = null;
  }

  @override
  Future<void> updateAuthTokens({
    required String token,
    required String refreshToken,
    String? sessionId,
  }) async {
    final user = currentUser.value;
    if (user == null) return;
    currentUser.value = user.copyWith(
      token: token,
      refreshToken: refreshToken,
      sessionId: sessionId?.isNotEmpty == true ? sessionId : user.sessionId,
    );
  }
}
