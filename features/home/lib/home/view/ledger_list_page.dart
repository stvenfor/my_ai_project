import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/ledger_list_controller.dart';
import 'package:module_home/home/widgets/transaction_list_item.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 个人收支列表（原二手车入口下的 transactions）。
class LedgerListPage extends GetView<LedgerListController> {
  const LedgerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      navBar: const AppNavBar(title: '收支', showBackButton: true),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.items.toList();
        final errorMessage = controller.errorMessage.value;

        if (isLoading && items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (errorMessage != null && items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMessage),
                FilledButton(onPressed: controller.loadInitial, child: const Text('重试')),
              ],
            ),
          );
        }
        if (items.isEmpty) {
          return const Center(child: Text('暂无收支记录'));
        }
        return AppRefreshView(
          onRefresh: controller.refresh,
          onLoad: controller.loadMore,
          enableLoad: controller.hasMore.value,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return TransactionListItem(
                key: ValueKey(item.id),
                item: item,
                onTap: () => Get.toNamed(
                  RoutePath.homeLedgerDetail,
                  arguments: item.id,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
