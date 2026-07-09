import 'package:get/get.dart';
import 'package:module_core/model/user.dart';

/// 用户会话抽象服务，业务模块只依赖此接口。
abstract class UserService extends GetxService {
  Rxn<User> get currentUser;

  bool get isLoggedIn => currentUser.value != null;

  Future<void> setUser(User user);

  Future<void> clearUser();
}

/// 可主动从底层刷新登录态的实现（如需要时由 auth 模块提供）。
abstract class SessionRefreshable {
  Future<void> refreshSession();
}
