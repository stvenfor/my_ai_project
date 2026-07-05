import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/model/search_page_model.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_discovery_section.dart';
import 'package:module_home/home/view/widgets/search_filter_section.dart';
import 'package:module_home/home/view/widgets/search_header_bar.dart';
import 'package:module_home/home/view/widgets/search_history_section.dart';
import 'package:module_home/home/view/widgets/search_rank_list_item.dart';
import 'package:module_home/home/view/widgets/search_sticky_tab_delegate.dart';

class SearchPage extends GetView<HomeSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeSearchController>()) {
      HomeSearchBinding().dependencies();
    }

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: SearchPageTheme.background,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            final handle =
                NestedScrollView.sliverOverlapAbsorberHandleFor(context);
            return [
              SliverOverlapAbsorber(
                handle: handle,
                sliver: const SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchHeaderBar(),
                      SearchHistorySection(),
                      SearchDiscoverySection(),
                      SearchFilterSection(),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SearchStickyTabBarDelegate(
                  tabBar: _buildTabBar(),
                  backgroundColor: SearchPageTheme.background,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: controller.tabController,
            children: [
              for (var i = 0; i < SearchRankTab.values.length; i++)
                _SearchRankTabList(tabIndex: i),
            ],
          ),
        ),
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: controller.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: SearchPageTheme.primaryGreen,
      unselectedLabelColor: SearchPageTheme.textGray,
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      indicatorColor: SearchPageTheme.primaryGreen,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: SearchPageTheme.divider,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: [
        for (final tab in SearchRankTab.values) Tab(text: tab.label),
      ],
    );
  }
}

class _SearchRankTabList extends GetView<HomeSearchController> {
  const _SearchRankTabList({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.rankLists[tabIndex].toList();

      return Builder(
        builder: (context) {
          return CustomScrollView(
            key: PageStorageKey<String>('search_rank_$tabIndex'),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return SearchRankListItem(
                        item: item,
                        onTap: () => controller.onRankItemTap(item),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
