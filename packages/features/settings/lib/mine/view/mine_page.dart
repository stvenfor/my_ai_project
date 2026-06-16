import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/widgets/mine_function_section_widget.dart';
import 'package:module_settings/mine/widgets/mine_header_widget.dart';

class MinePage extends GetView<MineController> {
  const MinePage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.mainTabRoot,
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: MineHeaderWidget(showBackButton: showBackButton),
            ),
          ),
          const SliverToBoxAdapter(child: MineFunctionSectionWidget()),
          SliverToBoxAdapter(
            child: SizedBox(height: AppSafeInsets.bottom(context) + 24),
          ),
        ],
      ),
    );
  }
}
