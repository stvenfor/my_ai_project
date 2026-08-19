import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_settings/mine/widgets/mine_function_section_widget.dart';
import 'package:module_settings/mine/widgets/mine_header_widget.dart';
import 'package:module_settings/mine/widgets/mine_menu_list_widget.dart';
import 'package:module_settings/mine/widgets/mine_quick_services_widget.dart';

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
      backgroundColor: MineTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 840
              ? MineTheme.contentMaxWidth
              : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: MineHeaderWidget(showBackButton: showBackButton),
                  ),
                  SliverToBoxAdapter(
                    child: MineQuickServicesWidget(
                      onTap: controller.onQuickServiceTap,
                    ),
                  ),
                  const SliverToBoxAdapter(child: MineFunctionSectionWidget()),
                  SliverToBoxAdapter(
                    child: MineMenuListWidget(onTap: controller.onMenuTap),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppSafeInsets.bottom(context) + 24),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
