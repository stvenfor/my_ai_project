import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_http/module_http.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_utils/module_utils.dart';

/// 重连后增量同步（Go BFF）。
class WsSyncApi {
  Future<WsSyncResult> sync({
    required int sinceSeq,
    required List<String> topics,
  }) async {
    AuthHttpConfig.ensureInitialized();

    final result = await HttpManager.instance.post<WsSyncResult>(
      RealtimeConfig.syncPath,
      data: {
        'sinceSeq': sinceSeq,
        'topics': topics,
      },
      converter: (json) => WsSyncResult.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final sync = result.data;
    if (!result.success || sync == null) {
      throw HttpRequestException(
        message: result.message ?? 'Realtime sync 失败',
        code: result.code?.toString(),
      );
    }

    LogUtils.i(
      '[WsSyncApi] sync sinceSeq=$sinceSeq topics=$topics events=${sync.events.length}',
    );
    return sync;
  }
}

class WsSyncResult {
  const WsSyncResult({
    required this.events,
    required this.latestSeq,
  });

  final List<RealtimeEnvelope> events;
  final int latestSeq;

  factory WsSyncResult.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'];
    final events = <RealtimeEnvelope>[];
    if (rawEvents is List) {
      for (final item in rawEvents) {
        if (item is Map) {
          events.add(
            RealtimeEnvelope.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return WsSyncResult(
      events: events,
      latestSeq: _asInt(json['latestSeq']) ?? 0,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
