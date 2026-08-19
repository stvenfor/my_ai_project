import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_utils/module_utils.dart';

/// 融云 Engine 持有（Mock / Real）。
class RongEngineHolder {
  RongEngineHolder({EnvironmentService? envService}) : _envService = envService;

  final EnvironmentService? _envService;
  bool _connected = false;
  ImSessionResult? _session;

  bool get isConnected => _connected;

  ImSessionResult? get session => _session;

  Future<void> connectMock({required ImSessionResult session}) async {
    _session = session;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _connected = true;
    final appKey = _envService?.rongAppKey ?? 'DEV_RONG_APP_KEY_PLACEHOLDER';
    LogUtils.i('[RongEngine] mock connected appKey=$appKey imUserId=${session.imUserId}');
  }

  Future<void> connectReal({required ImSessionResult session}) async {
    if (RongImConfig.useMockIm) {
      return connectMock(session: session);
    }
    final appKey = _envService?.rongAppKey ?? 'DEV_RONG_APP_KEY_PLACEHOLDER';
    LogUtils.w(
      '[RongEngine] 真实 SDK 待控制台 AppKey 就绪后接入 appKey=$appKey',
    );
    // TODO: RCIMIWEngine.create(appKey) + connect(session.token)
    await connectMock(session: session);
  }

  Future<void> disconnect({String? reason}) async {
    _connected = false;
    _session = null;
    LogUtils.i('[RongEngine] disconnected reason=$reason env=${_envService?.currentEnv.value ?? AppEnv.test}');
  }
}
