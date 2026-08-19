import 'package:module_core/service/session_guard_service.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_auth/session/session_recovery.dart';

/// 将 auth 模块的 SessionGuard/Recovery 桥接到 core 契约。
class AuthSessionGuardService implements SessionGuardService {
  @override
  bool isForceLogoutError(Object error) =>
      SessionGuardHook.isForceLogoutError(error);

  @override
  Future<bool> tryRecover() => SessionRecovery.tryRecover();

  @override
  Future<void> handleIfForceLogout(Object error) =>
      SessionGuardHook.handleIfForceLogout(error);
}
