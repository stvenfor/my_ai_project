import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_core/core.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_core/service/im_user_profile_service.dart';
import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/api/im_user_profile_api.dart';
import 'package:module_rongcloud_im/backup/mock_im_backup_service.dart';
import 'package:module_rongcloud_im/cache/cached_im_user_profile_service.dart';
import 'package:module_rongcloud_im/engine/rong_engine_holder.dart';
import 'package:module_rongcloud_im/im_binding.dart';
import 'package:module_rongcloud_im/registry/im_user_id_registry.dart';
import 'package:module_rongcloud_im/session/im_session_service_impl.dart';
import 'package:module_rongcloud_im/telemetry/im_telemetry.dart';
import 'package:module_utils/module_utils.dart';

class ImInitializer {
  ImInitializer._();

  static ImSessionServiceImpl? _sessionImpl;

  static ImSessionService? get session =>
      Get.isRegistered<ImSessionService>() ? Get.find<ImSessionService>() : null;

  static Future<void> initDeferred() async {
    ImBinding().dependencies();
    _sessionImpl = Get.find<ImSessionService>() as ImSessionServiceImpl;

    PrivacyConsentService.onGranted = _chainPrivacy(
      PrivacyConsentService.onGranted,
    );

    AuthSession.onAfterLogin = _chainAfterLogin(AuthSession.onAfterLogin);
    AuthSession.onAfterLogout = _chainAfterLogout(AuthSession.onAfterLogout);

    if (Get.isRegistered<EnvironmentService>()) {
      final env = Get.find<EnvironmentService>();
      final prev = env.onEnvChanged;
      env.onEnvChanged = (next) async {
        await prev?.call(next);
        await _sessionImpl?.disconnect(reason: 'env_changed');
        await tryConnectIfReady();
      };
    }

    await tryConnectIfReady();
  }

  static Future<void> Function()? _chainPrivacy(Future<void> Function()? prev) {
    return () async {
      await prev?.call();
      await tryConnectIfReady();
    };
  }

  static Future<void> Function()? _chainAfterLogin(Future<void> Function()? prev) {
    return () async {
      await prev?.call();
      await tryConnectIfReady();
    };
  }

  static Future<void> Function()? _chainAfterLogout(Future<void> Function()? prev) {
    return () async {
      await _sessionImpl?.disconnect(reason: 'logout');
      await prev?.call();
      if (Get.isRegistered<ImBackupService>()) {
        await Get.find<ImBackupService>().flushPending();
      }
    };
  }

  static bool _privacyGranted() =>
      SpManager.instance.getBool(SpKeys.privacyConsentGranted) ?? false;

  static Future<void> tryConnectIfReady() async {
    if (!_privacyGranted()) {
      LogUtils.i('[ImInitializer] skip: privacy not granted');
      return;
    }
    if (!AuthSession.isLoggedIn) {
      LogUtils.i('[ImInitializer] skip: not logged in');
      return;
    }
    final user = AuthSession.maybeService?.currentUser.value;
    if (user == null || user.id.isEmpty) return;

    final session = _sessionImpl;
    if (session == null) return;
    if (session.currentState == ImConnectionState.connected) return;

    await session.connect(bizUserId: user.id);
  }

  static Future<void> dispose() async {
    await _sessionImpl?.dispose();
    _sessionImpl = null;
  }
}
