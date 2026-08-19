import 'package:module_linking/models/push_payload.dart';

/// 推送服务抽象（极光 / Mock）。
abstract class PushService {
  bool get isInitialized;

  Future<void> initialize();

  Future<String?> getRegistrationId();

  Future<void> setAlias(String alias);

  Future<void> clearAlias();

  /// 模拟收到一条推送（调试 / mock）。
  Future<void> simulatePush(PushPayload payload, {bool foreground = true});

  Future<void> dispose();
}
