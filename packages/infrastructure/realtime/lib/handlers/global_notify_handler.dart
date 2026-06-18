import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_realtime/store/realtime_seq_store.dart';
import 'package:module_realtime/telemetry/realtime_telemetry.dart';
import 'package:module_realtime/ui/realtime_notify_banner_controller.dart';
import 'package:module_utils/module_utils.dart';

class GlobalNotifyPayload {
  const GlobalNotifyPayload({
    required this.notifyId,
    required this.title,
    required this.body,
    this.extras = const {},
  });

  final String notifyId;
  final String title;
  final String body;
  final Map<String, dynamic> extras;

  factory GlobalNotifyPayload.fromEnvelope(RealtimeEnvelope envelope) {
    final p = envelope.payload;
    return GlobalNotifyPayload(
      notifyId: p['notifyId']?.toString() ?? envelope.id ?? '',
      title: p['title']?.toString() ?? '通知',
      body: p['body']?.toString() ?? '',
      extras: Map<String, dynamic>.from(p),
    );
  }
}

/// 处理 sys.notify（notifyId 服务端统一生成，客户端去重）。
class GlobalNotifyHandler {
  GlobalNotifyHandler({
    required NotifyDedupStore dedupStore,
    required RealtimeTelemetry telemetry,
    required RealtimeNotifyBannerController bannerController,
  })  : _dedupStore = dedupStore,
        _telemetry = telemetry,
        _bannerController = bannerController;

  final NotifyDedupStore _dedupStore;
  final RealtimeTelemetry _telemetry;
  final RealtimeNotifyBannerController _bannerController;

  Future<void> handle(RealtimeEnvelope envelope) async {
    if (envelope.eventName != 'sys.notify.show') return;
    final payload = GlobalNotifyPayload.fromEnvelope(envelope);
    if (payload.notifyId.isEmpty) {
      LogUtils.w('[GlobalNotify] missing notifyId');
      return;
    }

    final accept = await _dedupStore.shouldProcess(payload.notifyId);
    if (!accept) {
      LogUtils.d('[GlobalNotify] dedup skip notifyId=${payload.notifyId}');
      _telemetry.metric('notify_dedup_skip', params: {'notifyId': payload.notifyId});
      return;
    }

    _telemetry.metric('notify_arrive', params: {'notifyId': payload.notifyId});
    _bannerController.show(payload);
    _telemetry.metric('notify_banner_show', params: {'notifyId': payload.notifyId});
  }
}
