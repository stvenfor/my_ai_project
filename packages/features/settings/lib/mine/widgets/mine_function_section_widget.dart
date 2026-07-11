import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_settings/mine/widgets/mine_reorderable_function_grid.dart';

class MineFunctionSectionWidget extends StatelessWidget {
  const MineFunctionSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Text('个人功能', style: MineTheme.headline.copyWith(fontSize: 17)),
              const Spacer(),
              Text('长按拖动顺序', style: MineTheme.caption),
            ],
          ),
        ),
        Obx(() {
          final items = controller.functions.toList();
          return MineReorderableFunctionGrid(
            key: ValueKey(items.map((e) => e.id).join(',')),
            items: items,
            onReorder: controller.reorderFunction,
            onItemTap: controller.onFunctionTap,
          );
        }),
      ],
    );
  }
}
