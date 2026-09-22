import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_mall/mall/binding/mall_binding.dart';
import 'package:module_mall/mall/controller/mall_detail_controller.dart';
import 'package:module_mall/mall/controller/mall_order_detail_controller.dart';
import 'package:module_mall/mall/controller/mall_orders_controller.dart';
import 'package:module_mall/mall/view/mall_detail_page.dart';
import 'package:module_mall/mall/view/mall_order_detail_page.dart';
import 'package:module_mall/mall/view/mall_orders_page.dart';
import 'package:module_mall/mall/view/mall_page.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/route/route_path.dart';

class MallModule extends FeatureModule {
  @override
  String get moduleId => 'mall';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.mall: (_) {
          MallBinding().dependencies();
          return const MallPage();
        },
        RoutePath.mallDetail: (_) {
          final id = Get.arguments?.toString() ?? '';
          if (Get.isRegistered<MallDetailController>()) {
            Get.delete<MallDetailController>(force: true);
          }
          Get.put(MallDetailController(productId: id));
          return const MallDetailPage();
        },
        RoutePath.mallOrders: (_) {
          if (Get.isRegistered<MallOrdersController>()) {
            Get.delete<MallOrdersController>(force: true);
          }
          Get.put(MallOrdersController());
          return const MallOrdersPage();
        },
        RoutePath.mallOrderDetail: (_) {
          final raw = Get.arguments;
          final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
          if (Get.isRegistered<MallOrderDetailController>()) {
            Get.delete<MallOrderDetailController>(force: true);
          }
          Get.put(MallOrderDetailController(orderId: id));
          return const MallOrderDetailPage();
        },
      };
}
