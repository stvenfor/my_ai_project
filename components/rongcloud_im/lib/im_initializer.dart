import 'dart:async';

import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_rongcloud_im/im_binding.dart';
import 'package:module_rongcloud_im/session/im_session_service_impl.dart';
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

    AuthLifecycle.onAfterLogin = _chainAfterLogin(AuthLifecycle.onAfterLogin);
    AuthLifecycle.onAfterLogout =
        _chainAfterLogout(AuthLifecycle.onAfterLogout);

    if (Get.isRegistered<EnvironmentService>()) {
      final env = Get.find<EnvironmentService>();
      final prev = env.onEnvChanged;
      env.onEnvChanged = (next) async {
        await prev?.call(next);
        await _sessionImpl?.disconnect(reason: 'env_changed');
        await tryConnectIfReady();
      };
    }

    // 不得阻塞 AppInitializer / Splash（后端不可达时会卡住启动页）。
    unawaited(tryConnectIfReady());
  }

  static Future<void> Function()? _chainPrivacy(Future<void> Function()? prev) {
    return () async {
      await prev?.call();
      unawaited(tryConnectIfReady());
    };
  }

  static Future<void> Function()? _chainAfterLogin(Future<void> Function()? prev) {
    return () async {
      await prev?.call();
      unawaited(tryConnectIfReady());
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
    if (!AuthLifecycle.isLoggedIn) {
      LogUtils.i('[ImInitializer] skip: not logged in');
      return;
    }
    final user = AuthLifecycle.currentUser;
    if (user == null || user.id.isEmpty) return;

    final session = _sessionImpl;
    if (session == null) return;
    if (session.currentState == ImConnectionState.connected) return;

    try {
      await session
          .connect(bizUserId: user.id)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      LogUtils.w('[ImInitializer] connect timed out');
    } catch (e, st) {
      LogUtils.e('[ImInitializer] connect failed', e, st);
    }
  }

  static Future<void> dispose() async {
    await _sessionImpl?.dispose();
    _sessionImpl = null;
  }
}
