import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/used_car_list_controller.dart';
import 'package:module_home/home/widgets/transaction_list_item.dart';
import 'package:module_route/route/route_path.dart';

class UsedCarListPage extends GetView<UsedCarListController> {
  const UsedCarListPage({super.key});

  static const _bgColor = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '二手车', showBackButton: true),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.items.toList();
        final errorMessage = controller.errorMessage.value;
        final hasMore = controller.hasMore.value;
        final isLoadingMore = controller.isLoadingMore.value;

        if (isLoading && items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null && items.isEmpty) {
          return _ErrorState(
            message: errorMessage,
            onRetry: controller.loadInitial,
          );
        }

        if (items.isEmpty) {
          return _EmptyState(onRefresh: controller.refresh);
        }

        return AppRefreshView(
          onRefresh: controller.refresh,
          onLoad: controller.loadMore,
          enableLoad: hasMore,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: items.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final item = items[index];
              return TransactionListItem(
                key: ValueKey(item.id),
                item: item,
                onTap: () => Get.toNamed(
                  RoutePath.homeUsedCarDetail,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('暂无交易记录', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('加载失败'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('点击重试')),
        ],
      ),
    );
  }
}
