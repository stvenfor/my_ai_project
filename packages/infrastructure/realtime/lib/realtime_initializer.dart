import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_core/service/app_realtime_client.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_realtime/client/app_realtime_client_impl.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/realtime_binding.dart';
import 'package:module_realtime/store/realtime_seq_store.dart';
import 'package:module_utils/module_utils.dart';

/// Realtime 模块初始化。
class RealtimeInitializer {
  RealtimeInitializer._();

  static AppRealtimeClientImpl? _clientImpl;
  static AppLifecycleListener? _lifecycleListener;

  static AppRealtimeClient? get client =>
      Get.isRegistered<AppRealtimeClient>() ? Get.find<AppRealtimeClient>() : null;

  static Future<void> initDeferred() async {
    RealtimeBinding().dependencies();

    final impl = Get.find<AppRealtimeClient>() as AppRealtimeClientImpl;
    _clientImpl = impl;
    await impl.prepare();
    await Get.find<NotifyDedupStore>().load();

    PrivacyConsentService.onGranted = _chainPrivacyGranted(
      PrivacyConsentService.onGranted,
    );

    AuthSession.onAfterLogout = _chainAfterLogout(AuthSession.onAfterLogout);
    AuthSession.onAfterLogin = _chainAfterLogin(AuthSession.onAfterLogin);

    _lifecycleListener = AppLifecycleListener(
      onStateChange: impl.onAppLifecycle,
    );

    if (Get.isRegistered<EnvironmentService>()) {
      final env = Get.find<EnvironmentService>();
      final prev = env.onEnvChanged;
      env.onEnvChanged = (next) async {
        await prev?.call(next);
        await _onEnvChanged();
      };
    }

    await tryConnectIfReady();
  }

  static Future<void> Function()? _chainPrivacyGranted(
    Future<void> Function()? previous,
  ) {
    return () async {
      await previous?.call();
      await tryConnectIfReady();
    };
  }

  static Future<void> Function()? _chainAfterLogin(
    Future<void> Function()? previous,
  ) {
    return () async {
      await previous?.call();
      await tryConnectIfReady();
    };
  }

  static Future<void> Function()? _chainAfterLogout(
    Future<void> Function()? previous,
  ) {
    return () async {
      await onLogout();
      await previous?.call();
    };
  }

  static bool _privacyGranted() =>
      SpManager.instance.getBool(SpKeys.privacyConsentGranted) ?? false;

  static Future<void> tryConnectIfReady() async {
    if (!_privacyGranted()) {
      LogUtils.i('[Realtime] skip connect: privacy not granted');
      return;
    }
    if (!AuthSession.isLoggedIn) {
      LogUtils.i('[Realtime] skip connect: not logged in');
      return;
    }
    final c = _clientImpl;
    if (c == null) return;

    await c.connect();
    await c.subscribeTopics([RealtimeTopics.sysNotify, RealtimeTopics.presenceBulk]);
  }

  static Future<void> onLogout() async {
    await _clientImpl?.disconnect(reason: 'logout', clearQueue: false);
  }

  static Future<void> _onEnvChanged() async {
    await _clientImpl?.disconnect(reason: 'env_changed');
    await tryConnectIfReady();
  }

  static Future<void> dispose() async {
    _lifecycleListener?.dispose();
    await _clientImpl?.dispose();
    _clientImpl = null;
  }
}
