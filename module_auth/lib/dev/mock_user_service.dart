import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// 独立运行时使用，不持久化。
class MockUserService extends UserService {
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
}
