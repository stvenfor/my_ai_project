import 'dart:async';

import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_utils/module_utils.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// 融云 Engine 持有（Mock / Real）。
class RongEngineHolder {
  RongEngineHolder({EnvironmentService? envService}) : _envService = envService;

  final EnvironmentService? _envService;
  bool _connected = false;
  ImSessionResult? _session;
  RCIMIWEngine? _engine;

  bool get isConnected => _connected;

  ImSessionResult? get session => _session;

  RCIMIWEngine? get engine => _engine;

  bool get _mock => RongImConfig.useMockImFor(_envService?.rongAppKey);

  Future<void> connectMock({required ImSessionResult session}) async {
    _session = session;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _connected = true;
    final appKey = _envService?.rongAppKey ?? 'DEV_RONG_APP_KEY_PLACEHOLDER';
    LogUtils.i('[RongEngine] mock connected appKey=$appKey imUserId=${session.imUserId}');
  }

  Future<void> connectReal({required ImSessionResult session}) async {
    if (_mock) {
      return connectMock(session: session);
    }
    final appKey = (_envService?.rongAppKey ?? '').trim();
    if (appKey.isEmpty || appKey.toUpperCase().contains('PLACEHOLDER')) {
      throw StateError('融云 App Key 未配置');
    }
    _session = session;
    final options = RCIMIWEngineOptions.create();
    _engine = await RCIMIWEngine.create(appKey, options);
    final completer = Completer<void>();
    final code = await _engine!.connect(
      session.token,
      RongImConfig.connectTimeoutSeconds,
      callback: RCIMIWConnectCallback(
        onDatabaseOpened: (int? c) {},
        onConnected: (int? c, String? userId) {
          if (completer.isCompleted) return;
          if (c == 0) {
            completer.complete();
          } else {
            completer.completeError(StateError('融云连接失败 code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('融云 connect 返回 code=$code'));
    }
    await completer.future.timeout(
      const Duration(seconds: RongImConfig.connectTimeoutSeconds + 5),
    );
    _connected = true;
    LogUtils.i('[RongEngine] real connected appKey=$appKey imUserId=${session.imUserId}');
  }

  Future<void> disconnect({String? reason}) async {
    final engine = _engine;
    _engine = null;
    _connected = false;
    _session = null;
    if (engine != null) {
      try {
        await engine.disconnect(false);
      } catch (e, st) {
        LogUtils.e('[RongEngine] disconnect error', e, st);
      }
    }
    LogUtils.i(
      '[RongEngine] disconnected reason=$reason env=${_envService?.currentEnv.value ?? AppEnv.test}',
    );
  }
}
