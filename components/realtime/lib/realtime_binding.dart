import 'package:get/get.dart';
import 'package:module_core/service/app_realtime_client.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_realtime/api/ws_sync_api.dart';
import 'package:module_realtime/api/ws_ticket_api.dart';
import 'package:module_realtime/client/app_realtime_client_impl.dart';
import 'package:module_realtime/handlers/global_notify_handler.dart';
import 'package:module_realtime/queue/outbound_queue_manager.dart';
import 'package:module_realtime/router/inbound_router.dart';
import 'package:module_realtime/store/realtime_seq_store.dart';
import 'package:module_realtime/telemetry/realtime_telemetry.dart';
import 'package:module_realtime/ui/realtime_notify_banner_controller.dart';

class RealtimeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RealtimeTelemetry>()) {
      Get.put(RealtimeTelemetry(), permanent: true);
    }
    if (!Get.isRegistered<RealtimeSeqStore>()) {
      Get.put(RealtimeSeqStore(), permanent: true);
    }
    if (!Get.isRegistered<NotifyDedupStore>()) {
      Get.put(NotifyDedupStore(), permanent: true);
    }
    if (!Get.isRegistered<OutboundQueueManager>()) {
      Get.put(OutboundQueueManager(), permanent: true);
    }
    if (!Get.isRegistered<InboundRouter>()) {
      Get.put(InboundRouter(), permanent: true);
    }
    if (!Get.isRegistered<RealtimeNotifyBannerController>()) {
      Get.put(RealtimeNotifyBannerController(), permanent: true);
    }
    if (!Get.isRegistered<WsTicketApi>()) {
      Get.put(
        WsTicketApi(
          envService: Get.isRegistered<EnvironmentService>()
              ? Get.find<EnvironmentService>()
              : null,
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<WsSyncApi>()) {
      Get.put(WsSyncApi(), permanent: true);
    }
    if (!Get.isRegistered<GlobalNotifyHandler>()) {
      Get.put(
        GlobalNotifyHandler(
          dedupStore: Get.find<NotifyDedupStore>(),
          telemetry: Get.find<RealtimeTelemetry>(),
          bannerController: Get.find<RealtimeNotifyBannerController>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AppRealtimeClient>()) {
      Get.put<AppRealtimeClient>(
        AppRealtimeClientImpl(
          ticketApi: Get.find<WsTicketApi>(),
          syncApi: Get.find<WsSyncApi>(),
          outboundQueue: Get.find<OutboundQueueManager>(),
          seqStore: Get.find<RealtimeSeqStore>(),
          router: Get.find<InboundRouter>(),
          notifyHandler: Get.find<GlobalNotifyHandler>(),
          telemetry: Get.find<RealtimeTelemetry>(),
        ),
        permanent: true,
      );
    }
  }
}
