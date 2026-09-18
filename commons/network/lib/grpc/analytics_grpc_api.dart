import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:module_core/core.dart';
import 'package:module_http/grpc/backend_grpc_config.dart';
import 'package:module_http/grpc/generated/analytics/v1/analytics.pbgrpc.dart';

/// 数据分析 gRPC 客户端（List + Get，metadata 对齐 HTTP 鉴权头）。
class AnalyticsGrpcApi {
  AnalyticsGrpcApi({ClientChannel? channel})
      : _ownsChannel = channel == null,
        _channel = channel ??
            ClientChannel(
              BackendGrpcConfig.resolveHost(),
              port: BackendGrpcConfig.port,
              options: const ChannelOptions(
                credentials: ChannelCredentials.insecure(),
              ),
            );

  final bool _ownsChannel;
  final ClientChannel _channel;
  late final AnalyticsServiceClient _client =
      AnalyticsServiceClient(_channel);

  Future<ListAnalyticsRecordsResponse> list({
    required int page,
    int pageSize = 10,
  }) {
    return _client.listAnalyticsRecords(
      ListAnalyticsRecordsRequest()
        ..page = page
        ..pageSize = pageSize,
      options: CallOptions(metadata: _authMetadata()),
    );
  }

  Future<AnalyticsRecord> getById(int id) async {
    final resp = await _client.getAnalyticsRecord(
      GetAnalyticsRecordRequest()..id = Int64(id),
      options: CallOptions(metadata: _authMetadata()),
    );
    if (!resp.hasItem()) {
      throw StateError('记录不存在');
    }
    return resp.item;
  }

  Map<String, String> _authMetadata() {
    final user = Get.isRegistered<UserService>()
        ? Get.find<UserService>().currentUser.value
        : null;
    final headers = <String, String>{};
    final token = user?.token;
    if (token != null && token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }
    final sessionId = user?.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      headers['x-session-id'] = sessionId;
    }
    final deviceId = user?.deviceId;
    if (deviceId != null && deviceId.isNotEmpty) {
      headers['x-device-id'] = deviceId;
    }
    return headers;
  }

  Future<void> dispose() async {
    if (_ownsChannel) {
      await _channel.shutdown();
    }
  }
}
