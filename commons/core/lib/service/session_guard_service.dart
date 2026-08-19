/// 会话失效/恢复抽象：由 features/auth 注册实现，components 按需 Get.find。
abstract class SessionGuardService {
  bool isForceLogoutError(Object error);

  Future<bool> tryRecover();

  Future<void> handleIfForceLogout(Object error);
}
