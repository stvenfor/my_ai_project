import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/handlers/global_notify_handler.dart';

class RealtimeNotifyBannerData {
  const RealtimeNotifyBannerData({
    required this.notifyId,
    required this.title,
    required this.body,
    this.onTap,
  });

  final String notifyId;
  final String title;
  final String body;
  final VoidCallback? onTap;
}

/// 前台全局通知 Banner（队列 + 自动消失 + 点击跳转）。
///
/// UI 由 [RealtimeNotifyBannerHost] 渲染，收到 [banner] / [dismissing] 变更后立即展示。
class RealtimeNotifyBannerController extends GetxController {
  /// 当前展示中的 Banner。
  final Rxn<RealtimeNotifyBannerData> banner = Rxn<RealtimeNotifyBannerData>();

  /// Host 收到 true 后播放退出动画，再调用 [finishDismiss]。
  final RxBool dismissing = false.obs;

  final List<RealtimeNotifyBannerData> _queue = [];
  Timer? _autoDismissTimer;

  void show(GlobalNotifyPayload payload, {VoidCallback? onTap}) {
    showBanner(
      RealtimeNotifyBannerData(
        notifyId: payload.notifyId,
        title: payload.title,
        body: payload.body,
        onTap: onTap,
      ),
    );
  }

  void showBanner(RealtimeNotifyBannerData data) {
    if (banner.value != null || dismissing.value) {
      _queue.add(data);
      return;
    }
    _present(data);
  }

  void _present(RealtimeNotifyBannerData data) {
    dismissing.value = false;
    banner.value = data;
    _resetAutoDismissTimer();
  }

  void requestDismiss() {
    if (banner.value == null || dismissing.value) return;
    _cancelAutoDismissTimer();
    dismissing.value = true;
  }

  void finishDismiss() {
    dismissing.value = false;
    banner.value = null;
    if (_queue.isNotEmpty) {
      _present(_queue.removeAt(0));
    }
  }

  void handleTap() {
    banner.value?.onTap?.call();
    requestDismiss();
  }

  void dismiss() => requestDismiss();

  void _resetAutoDismissTimer() {
    _cancelAutoDismissTimer();
    _autoDismissTimer =
        Timer(RealtimeConfig.notifyBannerAutoDismiss, requestDismiss);
  }

  void _cancelAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
  }

  @override
  void onClose() {
    _cancelAutoDismissTimer();
    _queue.clear();
    banner.value = null;
    dismissing.value = false;
    super.onClose();
  }
}
