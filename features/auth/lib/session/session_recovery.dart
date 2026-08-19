import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// 同设备 session 失效时的静默恢复（refresh + 同步 device/session）。
class SessionRecovery {
  SessionRecovery._();

  static bool _recovering = false;

  /// 尝试用 refresh_token 恢复会话；成功则更新本地 token / session_id。
  static Future<bool> tryRecover() async {
    if (_recovering || !AuthSession.isLoggedIn) return false;
    if (!Get.isRegistered<AuthService>() ||
        !Get.isRegistered<UserService>()) {
      return false;
    }

    final auth = Get.find<AuthService>();
    if (auth is! SessionRefreshable) return false;

    _recovering = true;
    try {
      await syncStoredDeviceId();
      await (auth as SessionRefreshable).refreshSession();
      return AuthSession.isLoggedIn;
    } catch (error, stackTrace) {
      LogUtils.w('[SessionRecovery] recover failed', error, stackTrace);
      return false;
    } finally {
      _recovering = false;
    }
  }

  /// 启动时修正历史占位 device_id，避免与后端 Redis 会话不一致。
  static Future<void> syncStoredDeviceId() async {
    if (!Get.isRegistered<UserService>()) return;
    final service = Get.find<UserService>();
    final user = service.currentUser.value;
    if (user == null) return;

    final stableId = await DeviceAuthContext.resolve();
    if (user.deviceId == stableId.deviceId) return;
    if (user.deviceId.isEmpty ||
        DeviceInfoUtils.isPlaceholderDeviceId(user.deviceId)) {
      await service.setUser(user.copyWith(deviceId: stableId.deviceId));
    }
  }
}
