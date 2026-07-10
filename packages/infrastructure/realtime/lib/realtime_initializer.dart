import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_core/model/realtime/realtime_connection_state.dart';
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

    await tryConnectIfReady(trigger: 'app_startup');
  }

  static Future<void> Function()? _chainPrivacyGranted(
    Future<void> Function()? previous,
  ) {
    return () async {
      await previous?.call();
      await tryConnectIfReady(trigger: 'privacy_granted');
    };
  }

  static Future<void> Function()? _chainAfterLogin(
    Future<void> Function()? previous,
  ) {
    return () async {
      await previous?.call();
      await tryConnectIfReady(trigger: 'after_login');
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

  static Future<void> tryConnectIfReady({String trigger = 'manual'}) async {
    final privacyGranted = _privacyGranted();
    final loggedIn = AuthSession.isLoggedIn;
    final user = AuthSession.maybeService?.currentUser.value;
    final currentState = _clientImpl?.currentState;
    LogUtils.i(
      '[Realtime] tryConnect trigger=$trigger '
      'privacy=$privacyGranted loggedIn=$loggedIn '
      'user=${user?.name.isNotEmpty == true ? user!.name : user?.id ?? 'none'} '
      'state=${currentState?.label ?? 'n/a'}',
    );

    if (!privacyGranted) {
      LogUtils.i('[Realtime] skip connect: privacy not granted (trigger=$trigger)');
      return;
    }
    if (!loggedIn) {
      LogUtils.i('[Realtime] skip connect: not logged in (trigger=$trigger)');
      return;
    }
    final c = _clientImpl;
    if (c == null) {
      LogUtils.w('[Realtime] skip connect: client not ready (trigger=$trigger)');
      return;
    }

    if (c.currentState.isActive) {
      LogUtils.i(
        '[Realtime] skip connect: already ${c.currentState.label} (trigger=$trigger)',
      );
      return;
    }

    LogUtils.i('[Realtime] connecting... trigger=$trigger mock=${RealtimeConfig.useMockGateway}');
    await c.connect();
    await c.subscribeTopics([RealtimeTopics.sysNotify, RealtimeTopics.presenceBulk]);

    final connected = await _waitUntilConnected(
      timeout: const Duration(seconds: 8),
    );
    LogUtils.i(
      '[Realtime] connect result trigger=$trigger success=$connected '
      'state=${c.currentState.label} lastSeq=${c.lastSeq} '
      'topics=${RealtimeTopics.sysNotify},${RealtimeTopics.presenceBulk}',
    );
    if (!connected) {
      LogUtils.w(
        '[Realtime] connect not ready within timeout trigger=$trigger '
        'state=${c.currentState.label} — check backend / token / network',
      );
    }
  }

  static Future<bool> _waitUntilConnected({required Duration timeout}) async {
    final c = _clientImpl;
    if (c == null) return false;
    if (c.currentState.isActive) return true;

    try {
      await c.connectionState
          .firstWhere(
            (state) =>
                state.isActive || state == RealtimeConnectionState.failed,
          )
          .timeout(timeout);
      return c.currentState.isActive;
    } on TimeoutException {
      return c.currentState.isActive;
    }
  }

  static Future<void> onLogout() async {
    await _clientImpl?.disconnect(reason: 'logout', clearQueue: false);
  }

  static Future<void> _onEnvChanged() async {
    await _clientImpl?.disconnect(reason: 'env_changed');
    await tryConnectIfReady(trigger: 'env_changed');
  }

  static Future<void> dispose() async {
    _lifecycleListener?.dispose();
    await _clientImpl?.dispose();
    _clientImpl = null;
  }
}
