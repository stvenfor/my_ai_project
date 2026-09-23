import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';
import 'package:module_home/new_car_follow/viewmodel/new_car_follow_list_viewmodel.dart';
import 'package:module_home/new_car_follow/widgets/follow_sticky_tab_bar_delegate.dart';
import 'package:module_home/new_car_follow/widgets/new_car_follow_empty_state.dart';
import 'package:module_home/new_car_follow/widgets/new_car_follow_list_item.dart';
import 'package:module_home/new_car_follow/widgets/new_car_follow_profile_header.dart';
import 'package:wys_router/src/route/route_path.dart';

class NewCarFollowListPage extends GetView<NewCarFollowListViewModel> {
  const NewCarFollowListPage({super.key});

  static const _bgColor = Color(0xFFF5F6F8);

  Future<void> _openCreate() async {
    final ok = await Get.toNamed(RoutePath.homeNewCarFollowCreate);
    if (ok == true) controller.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '新车跟进', showBackButton: true),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final handle =
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context);
              return [
                SliverOverlapAbsorber(
                  handle: handle,
                  sliver: Obx(
                    () => SliverToBoxAdapter(
                      child: Column(
                        children: [
                          NewCarFollowProfileHeader(
                            summary: controller.summary.value,
                          ),
                          if (controller.error.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                controller.error.value,
                                style: const TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: FollowStickyTabBarDelegate(tabBar: _buildTabBar()),
                ),
              ];
            },
            body: TabBarView(
              controller: controller.tabController,
              children: [
                for (var i = 0; i < NewCarFollowTab.values.length; i++)
                  _FollowTabList(tabIndex: i, onCreate: _openCreate),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: AppSafeInsets.bottom(context) + 16,
            child: _CreateFab(onTap: _openCreate),
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
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        for (final tab in NewCarFollowTab.values) Tab(text: tab.label),
      ],
    );
  }
}

class _FollowTabList extends GetView<NewCarFollowListViewModel> {
  const _FollowTabList({required this.tabIndex, required this.onCreate});

  final int tabIndex;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    final state = controller.tabStates[tabIndex];

    return Obx(() {
      final items = state.items;
      final isRefreshing = state.isRefreshing.value;
      final isLoadingMore = state.isLoadingMore.value;
      final hasMore = state.hasMore.value;

      Future<void> onRefresh() => controller.refreshTab(tabIndex);

      if (items.isEmpty && !isRefreshing && state.loaded.value) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: Builder(
            builder: (context) {
              return CustomScrollView(
                key: PageStorageKey<String>('follow_empty_$tabIndex'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: NewCarFollowEmptyState(onCreate: onCreate),
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
                key: PageStorageKey<String>('follow_list_$tabIndex'),
                physics: const AlwaysScrollableScrollPhysics(),
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
                            if (!hasMore && items.isNotEmpty) {
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
                          return NewCarFollowListItem(
                            item: item,
                            onTap: () => Get.toNamed(
                              RoutePath.homeNewCarFollowDetail,
                              arguments: item.fileId,
                            ),
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

class _CreateFab extends StatelessWidget {
  const _CreateFab({required this.onTap});

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
                '新建跟进档案',
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
