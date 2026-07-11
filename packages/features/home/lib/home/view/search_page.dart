import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_discovery_section.dart';
import 'package:module_home/home/view/widgets/search_filter_section.dart';
import 'package:module_home/home/view/widgets/search_header_bar.dart';
import 'package:module_home/home/view/widgets/search_history_section.dart';
import 'package:module_home/home/view/widgets/search_rank_list_item.dart';
import 'package:module_home/home/view/widgets/search_rank_tab_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  HomeSearchController get controller => Get.find<HomeSearchController>();

  late final List<Worker> _workers;
  int _selectedRankTab = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeSearchController>()) {
      HomeSearchBinding().dependencies();
    }

    _workers = [
      ever<List<String>>(controller.searchHistory, (_) => _scheduleRebuild()),
      ever<List<String>>(controller.searchDiscovery, (_) => _scheduleRebuild()),
      ever<List<String>>(controller.filterTags, (_) => _scheduleRebuild()),
    ];
  }

  void _scheduleRebuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _onRankTabSelected(int index) {
    if (_selectedRankTab == index) return;
    setState(() => _selectedRankTab = index);
  }

  @override
  void dispose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = controller.searchHistory.toList();
    final discovery = controller.searchDiscovery.toList();
    final filterTags = controller.filterTags.toList();
    final rankItems = controller.rankLists[_selectedRankTab].toList();

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: SearchPageTheme.background,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SearchPageTheme.contentMaxWidth,
            ),
            child: Column(
              children: [
                const SearchHeaderBar(),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (history.isNotEmpty)
                        SearchHistorySection(
                          history: history,
                          onClear: controller.clearHistory,
                          onTagTap: controller.onTagTap,
                        )
                      else
                        const SizedBox(height: 8),
                      SearchDiscoverySection(
                        discovery: discovery,
                        onRefresh: controller.refreshDiscovery,
                        onTagTap: controller.onTagTap,
                      ),
                      SearchFilterSection(
                        tags: filterTags,
                        onTagTap: controller.onTagTap,
                      ),
                      SearchRankTabBar(
                        selectedIndex: _selectedRankTab,
                        onSelected: _onRankTabSelected,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: DecoratedBox(
                          decoration: SearchPageTheme.groupedCardDecoration,
                          child: Column(
                            children: [
                              for (var i = 0; i < rankItems.length; i++)
                                SearchRankListItem(
                                  item: rankItems[i],
                                  onTap: () =>
                                      controller.onRankItemTap(rankItems[i]),
                                  showDivider: i < rankItems.length - 1,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
