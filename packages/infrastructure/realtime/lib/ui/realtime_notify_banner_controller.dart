import 'package:get/get.dart';
import 'package:module_realtime/handlers/global_notify_handler.dart';

class RealtimeNotifyBannerData {
  const RealtimeNotifyBannerData({
    required this.notifyId,
    required this.title,
    required this.body,
  });

  final String notifyId;
  final String title;
  final String body;
}

/// 前台全局通知 Banner。
class RealtimeNotifyBannerController extends GetxController {
  final Rxn<RealtimeNotifyBannerData> banner = Rxn<RealtimeNotifyBannerData>();

  void show(GlobalNotifyPayload payload) {
    banner.value = RealtimeNotifyBannerData(
      notifyId: payload.notifyId,
      title: payload.title,
      body: payload.body,
    );
  }

  void dismiss() => banner.value = null;
}
