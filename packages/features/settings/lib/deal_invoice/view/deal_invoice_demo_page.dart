import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';
import 'package:module_settings/deal_invoice/viewmodel/deal_invoice_demo_viewmodel.dart';
import 'package:module_settings/deal_invoice/widgets/deal_invoice_empty_state.dart';
import 'package:module_settings/deal_invoice/widgets/deal_invoice_list_item.dart';
import 'package:module_settings/deal_invoice/widgets/deal_invoice_profile_header.dart';
import 'package:module_settings/deal_invoice/widgets/sticky_tab_bar_delegate.dart';

/// 新车成交示例页：悬浮 Tab + 下拉刷新 + 上拉加载更多。
class DealInvoiceDemoPage extends GetView<DealInvoiceDemoViewModel> {
  const DealInvoiceDemoPage({super.key});

  static const _bgColor = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '新车成交', showBackButton: true),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final handle =
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context);
              return [
                SliverOverlapAbsorber(
                  handle: handle,
                  sliver: SliverToBoxAdapter(
                    child: Obx(
                      () => DealInvoiceProfileHeader(
                        stats: controller.stats.value,
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyTabBarDelegate(
                    tabBar: _buildTabBar(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: controller.tabController,
              children: [
                for (var i = 0; i < DealInvoiceTab.values.length; i++)
                  _InvoiceTabList(tabIndex: i),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: AppSafeInsets.bottom(context) + 16,
            child: _UploadFab(onTap: controller.onUploadTap),
          ),
        ],
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: controller.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: const Color(0xFF1A1A1A),
      unselectedLabelColor: Colors.grey.shade600,
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      indicatorColor: const Color(0xFF3B8CFF),
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: [
        for (final tab in DealInvoiceTab.values) Tab(text: tab.label),
      ],
    );
  }
}

class _InvoiceTabList extends GetView<DealInvoiceDemoViewModel> {
  const _InvoiceTabList({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final state = controller.tabStates[tabIndex];

    return Obx(() {
      final items = state.items;
      final isRefreshing = state.isRefreshing.value;
      final isLoadingMore = state.isLoadingMore.value;
      final hasMore = state.hasMore.value;

      Future<void> onRefresh() => controller.refreshTab(tabIndex);

      if (items.isEmpty && !isRefreshing) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: Builder(
            builder: (context) {
              return CustomScrollView(
                key: PageStorageKey<String>('deal_invoice_empty_$tabIndex'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: DealInvoiceEmptyState(
                      onUpload: controller.onUploadTap,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: Builder(
          builder: (context) {
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 120 &&
                    hasMore &&
                    !isLoadingMore) {
                  controller.loadMore(tabIndex);
                }
                return false;
              },
              child: CustomScrollView(
                key: PageStorageKey<String>('deal_invoice_list_$tabIndex'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == items.length) {
                            if (isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!hasMore) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    '没有更多了',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox(height: 16);
                          }

                          final item = items[index];
                          return DealInvoiceListItem(
                            item: item,
                            onTap: () => controller.onItemTap(item),
                            onProcess: () => controller.onProcessTap(item),
                          );
                        },
                        childCount: items.length + 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _UploadFab extends StatelessWidget {
  const _UploadFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: const Color(0xFF3B8CFF).withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xFF3B8CFF),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: const SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 22),
              SizedBox(width: 6),
              Text(
                '上传成交发票',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
