import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/controller/mall_controller.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';
import 'package:module_mall/mall/view/widgets/mall_chrome.dart';
import 'package:module_mall/mall/view/widgets/mall_product_card.dart';

class MallPage extends GetView<MallController> {
  const MallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: MallTheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              const MallSearchHeader(),
              const Divider(height: 1, thickness: 1, color: MallTheme.separator),
              const MallCategoryTabs(),
              const Divider(height: 1, thickness: 1, color: MallTheme.separator),
              const MallFilterBar(),
              Expanded(child: _buildBody()),
            ],
          ),
          const MallFloatBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.loading.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.products.isEmpty) {
        return RefreshIndicator(
          color: MallTheme.accent,
          onRefresh: controller.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 120.h),
              Center(
                child: Text(
                  controller.errorMessage.value.isEmpty
                      ? '暂无商品'
                      : controller.errorMessage.value,
                  style: MallTheme.caption.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: MallTheme.accent,
        onRefresh: controller.onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
              controller.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              Obx(
                () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 80.h),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.h,
                    crossAxisSpacing: 8.w,
                    childCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final item = controller.products[index];
                      return MallProductCard(
                        item: item,
                        onTap: () => controller.onProductTap(item),
                      );
                    },
                  ),
                ),
              ),
              Obx(() {
                if (controller.loadingMore.value) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 88.h, top: 8.h),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  );
                }
                if (!controller.hasMore.value) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 88.h, top: 8.h),
                      child: Center(
                        child: Text('没有更多了', style: MallTheme.caption),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }),
            ],
          ),
        ),
      );
    });
  }
}
