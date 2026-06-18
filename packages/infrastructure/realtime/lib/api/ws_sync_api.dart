import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_utils/module_utils.dart';

/// 重连后增量同步（Mock 实现）。
class WsSyncApi {
  Future<WsSyncResult> sync({
    required int sinceSeq,
    required List<String> topics,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final events = <RealtimeEnvelope>[];

    var seq = sinceSeq;
    if (topics.contains('sys.notify') && sinceSeq < 1) {
      seq++;
      events.add(
        RealtimeEnvelope(
          id: 'sync_notify_1',
          type: 'event',
          topic: 'sys.notify',
          seq: seq,
          ts: DateTime.now().millisecondsSinceEpoch,
          payload: {
            'name': 'sys.notify.show',
            'notifyId': 'mock_notify_sync_001',
            'title': '同步通知',
            'body': '重连后 mock 补发的全局通知',
          },
        ),
      );
    }

    LogUtils.i(
      '[WsSyncApi] mock sync sinceSeq=$sinceSeq topics=$topics events=${events.length}',
    );

    return WsSyncResult(
      events: events,
      latestSeq: seq > sinceSeq ? seq : sinceSeq,
    );
  }
}

class WsSyncResult {
  const WsSyncResult({
    required this.events,
    required this.latestSeq,
  });

  final List<RealtimeEnvelope> events;
  final int latestSeq;
}
