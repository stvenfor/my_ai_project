import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
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

  factory ImSessionResult.fromJson(Map<String, dynamic> json) {
    return ImSessionResult(
      imUserId: (json['user_id'] ?? json['im_user_id'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      expiresInSeconds: _asInt(json['expires_in_seconds']) ?? 0,
    );
  }

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

/// POST /api/v1/im/session（Mock 或真实 BFF）。
class ImSessionApi {
  ImSessionApi({
    required ImUserIdRegistry registry,
    EnvironmentService? envService,
  })  : _registry = registry,
        _envService = envService;

  final ImUserIdRegistry _registry;
  final EnvironmentService? _envService;

  bool get _mock =>
      RongImConfig.useMockImFor(_envService?.rongAppKey);

  Future<ImSessionResult> createSession({
    required String bizUserId,
    String? displayName,
  }) async {
    if (_mock) {
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

    final body = <String, dynamic>{};
    final name = displayName?.trim() ?? '';
    if (name.isNotEmpty) {
      body['display_name'] = name;
    }

    final result = await HttpManager.instance.post<ResultModel<ImSessionResult>>(
      RongImConfig.sessionPath,
      data: body,
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => ImSessionResult.fromJson(m),
      ),
    );
    final envelope = result.data;
    final data = envelope?.data;
    if (envelope == null || !envelope.isSuccess || data == null || data.token.isEmpty) {
      throw HttpRequestException(
        message: envelope?.message ?? result.message ?? '获取 IM Token 失败',
        code: envelope?.code.toString() ?? result.code?.toString(),
      );
    }
    // 真实模式：业务 UUID = 融云 userId，不用本地 im_u_* 映射。
    LogUtils.i('[ImSessionApi] real session userId=${data.imUserId}');
    return data;
  }
}
