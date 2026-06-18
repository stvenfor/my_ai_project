import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_realtime/ui/realtime_notify_banner_controller.dart';

class RealtimeNotifyBannerHost extends StatelessWidget {
  const RealtimeNotifyBannerHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RealtimeNotifyBannerController>()) {
      return child;
    }
    final controller = Get.find<RealtimeNotifyBannerController>();
    return Stack(
      children: [
        child,
        Obx(() {
          final data = controller.banner.value;
          if (data == null) return const SizedBox.shrink();
          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 56, 12, 0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      data.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(data.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: controller.dismiss,
                    ),
                    onTap: controller.dismiss,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
