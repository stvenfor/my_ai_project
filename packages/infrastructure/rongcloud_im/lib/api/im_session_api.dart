import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_rongcloud_im/registry/im_user_id_registry.dart';
import 'package:module_utils/module_utils.dart';

class ImSessionResult {
  const ImSessionResult({
    required this.imUserId,
    required this.token,
    required this.expiresInSeconds,
  });

  final String imUserId;
  final String token;
  final int expiresInSeconds;
}

/// POST /im/session Mock。
class ImSessionApi {
  ImSessionApi({
    required ImUserIdRegistry registry,
    EnvironmentService? envService,
  })  : _registry = registry,
        _envService = envService;

  final ImUserIdRegistry _registry;
  final EnvironmentService? _envService;

  Future<ImSessionResult> createSession({required String bizUserId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final imUserId = await _registry.resolveImUserId(bizUserId);
    final env = _envService?.currentEnv.value ?? AppEnv.test;
    final appKey = _envService?.rongAppKey ?? 'DEV_RONG_APP_KEY_PLACEHOLDER';
    LogUtils.i('[ImSessionApi] mock session env=$env appKey=$appKey imUserId=$imUserId');
    return ImSessionResult(
      imUserId: imUserId,
      token: 'mock_rong_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresInSeconds: 3600,
    );
  }
}
