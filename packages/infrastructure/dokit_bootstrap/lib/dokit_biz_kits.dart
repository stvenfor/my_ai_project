import 'package:dokit/kit/biz/biz.dart';
import 'package:get/get.dart';
import 'package:module_route/route/route_path.dart';

/// 将壳工程已有调试页注册到 DoKit「业务专区」。
abstract final class DokitBizKits {
  static void register() {
    const group = 'biz';
    const tip = '项目内置调试入口';

    BizKitManager.instance.buildBizKit(
      key: 'biz_linking_debug',
      name: '链接与推送',
      group: group,
      desc: tip,
      action: () => Get.toNamed(RoutePath.linkingDebug),
    );
    BizKitManager.instance.buildBizKit(
      key: 'biz_realtime_debug',
      name: 'Realtime',
      group: group,
      desc: tip,
      action: () => Get.toNamed(RoutePath.realtimeDebug),
    );
    BizKitManager.instance.buildBizKit(
      key: 'biz_im_debug',
      name: '融云 IM',
      group: group,
      desc: tip,
      action: () => Get.toNamed(RoutePath.imDebug),
    );
    BizKitManager.instance.buildBizKit(
      key: 'biz_dialog_demo',
      name: '弹框调度',
      group: group,
      desc: tip,
      action: () => Get.toNamed(RoutePath.dialogDemo),
    );
    BizKitManager.instance.updateBizKitGroupTip(group, tip);
  }
}
