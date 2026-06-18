import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class InAppPushBannerData {
  const InAppPushBannerData({
    required this.title,
    required this.body,
    this.msgId,
    required this.onTap,
  });

  final String title;
  final String body;
  final String? msgId;
  final VoidCallback onTap;
}

/// 前台推送应用内 Banner 状态。
class InAppPushBannerController extends GetxController {
  final Rxn<InAppPushBannerData> banner = Rxn<InAppPushBannerData>();

  void show({
    required String title,
    required String body,
    String? msgId,
    required VoidCallback onTap,
  }) {
    banner.value = InAppPushBannerData(
      title: title,
      body: body,
      msgId: msgId,
      onTap: onTap,
    );
  }

  void dismiss() {
    banner.value = null;
  }
}
