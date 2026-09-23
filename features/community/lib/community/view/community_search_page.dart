import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/community_search_models.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/theme/community_theme.dart';
import 'package:module_community/community/viewmodel/community_search_viewmodel.dart';
import 'package:module_community/community/widgets/post_card_widget.dart';
import 'package:module_http/module_http.dart';

class CommunitySearchPage extends StatefulWidget {
  const CommunitySearchPage({super.key});

  @override
  State<CommunitySearchPage> createState() => _CommunitySearchPageState();
}

class _CommunitySearchPageState extends State<CommunitySearchPage> {
  late final CommunitySearchViewModel vm;

  static const _tabLabels = ['全部', '动态', '话题', '用户'];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CommunitySearchViewModel>()) {
      CommunitySearchBinding().dependencies();
    }
    vm = Get.find<CommunitySearchViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '搜索', showBackButton: true),
      backgroundColor: CommunityTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: vm.queryController,
              autofocus: true,
              onChanged: vm.onQueryChanged,
              onSubmitted: vm.onQuerySubmitted,
              decoration: InputDecoration(
                hintText: '搜索动态、话题、用户',
                hintStyle: TextStyle(color: CommunityTheme.labelTertiary),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: CommunityTheme.labelTertiary,
                ),
                filled: true,
                fillColor: CommunityTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => _SearchTabs(
                labels: _tabLabels,
                selected: vm.tabIndex.value,
                onSelected: vm.selectTab,
              )),
          Expanded(
            child: Obx(() {
              final q = vm.queryText.value.trim();
              if (q.isEmpty) {
                return _EmptyQueryBody(vm: vm);
              }
              if (vm.isLoading.value && vm.tabIndex.value != 0
                  ? _isSingleTabEmpty(vm)
                  : vm.allResult.value == null) {
                return const Center(child: CupertinoActivityIndicator());
              }
              return _SearchResultsBody(vm: vm);
            }),
          ),
        ],
      ),
    );
  }

  bool _isSingleTabEmpty(CommunitySearchViewModel vm) {
    return switch (vm.tabIndex.value) {
      1 => vm.posts.isEmpty,
      2 => vm.topics.isEmpty,
      3 => vm.users.isEmpty,
      _ => vm.allResult.value == null,
    };
  }
}

class _SearchTabs extends StatelessWidget {
  const _SearchTabs({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final active = index == selected;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[index],
                  style: CommunityTheme.headline.copyWith(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? CommunityTheme.labelPrimary
                        : CommunityTheme.labelSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 20 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: CommunityTheme.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyQueryBody extends StatelessWidget {
  const _EmptyQueryBody({required this.vm});

  final CommunitySearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (vm.history.isNotEmpty) ...[
          Row(
            children: [
              Text('搜索历史', style: CommunityTheme.headline.copyWith(fontSize: 15)),
              const Spacer(),
              GestureDetector(
                onTap: vm.clearHistory,
                child: Text(
                  '清空',
                  style: CommunityTheme.caption.copyWith(
                    color: CommunityTheme.labelTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.history
                .map(
                  (item) => _ChipTag(
                    label: item,
                    onTap: () => vm.applyKeyword(item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        Text('热门话题', style: CommunityTheme.headline.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        if (vm.hotTopics.isEmpty)
          Text('暂无热门话题', style: CommunityTheme.caption)
        else
          ...vm.hotTopics.map(
            (t) => _TopicRow(
              topic: t,
              onTap: () => vm.applyKeyword(t.name),
            ),
          ),
      ],
    );
  }
}

class _SearchResultsBody extends StatelessWidget {
  const _SearchResultsBody({required this.vm});

  final CommunitySearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.tabIndex.value == 0) {
      return _AllTabBody(vm: vm);
    }
    return _SingleTabList(vm: vm);
  }
}

class _AllTabBody extends StatelessWidget {
  const _AllTabBody({required this.vm});

  final CommunitySearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    final all = vm.allResult.value;
    if (all == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final hasAny = vm.posts.isNotEmpty ||
        vm.topics.isNotEmpty ||
        vm.users.isNotEmpty;
    if (!hasAny) {
      return Center(child: Text('暂无搜索结果', style: CommunityTheme.caption));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (vm.posts.isNotEmpty) ...[
          _SectionHeader(
            title: '动态',
            onMore: () => vm.selectTab(1),
            showMore: _sectionHasMore(all.posts.list.length, all.posts),
          ),
          ...vm.posts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostHit(post: p),
              )),
        ],
        if (vm.topics.isNotEmpty) ...[
          _SectionHeader(
            title: '话题',
            onMore: () => vm.selectTab(2),
            showMore: _sectionHasMore(all.topics.list.length, all.topics),
          ),
          ...vm.topics.map(
            (t) => _TopicRow(topic: t, onTap: () => vm.onTopicTap(t)),
          ),
        ],
        if (vm.users.isNotEmpty) ...[
          _SectionHeader(
            title: '用户',
            onMore: () => vm.selectTab(3),
            showMore: _sectionHasMore(all.users.list.length, all.users),
          ),
          ...vm.users.map(
            (u) => _UserRow(user: u, onFollow: () => vm.toggleFollow(u)),
          ),
        ],
      ],
    );
  }

  bool _sectionHasMore<T>(int shown, ListData<T> section) {
    final total = section.pagination?.total;
    if (total != null) return total > shown;
    return section.list.length >= CommunitySearchViewModel.allPreviewSize;
  }
}

class _SingleTabList extends StatelessWidget {
  const _SingleTabList({required this.vm});

  final CommunitySearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tab = vm.tabIndex.value;
    final empty = switch (tab) {
      1 => vm.posts.isEmpty,
      2 => vm.topics.isEmpty,
      3 => vm.users.isEmpty,
      _ => true,
    };
    if (empty && !vm.isLoading.value) {
      return Center(child: Text('暂无搜索结果', style: CommunityTheme.caption));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.extentAfter < 120 &&
            vm.hasMore.value &&
            !vm.isLoadingMore.value) {
          vm.search(loadMore: true);
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (tab == 1)
            ...vm.posts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostHit(post: p),
              ),
            ),
          if (tab == 2)
            ...vm.topics.map(
              (t) => _TopicRow(topic: t, onTap: () => vm.onTopicTap(t)),
            ),
          if (tab == 3)
            ...vm.users.map(
              (u) => _UserRow(user: u, onFollow: () => vm.toggleFollow(u)),
            ),
          if (vm.isLoadingMore.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (vm.hasMore.value)
            Center(
              child: TextButton(
                onPressed: () => vm.search(loadMore: true),
                child: const Text('加载更多'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onMore,
    required this.showMore,
  });

  final String title;
  final VoidCallback onMore;
  final bool showMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Text(title, style: CommunityTheme.headline.copyWith(fontSize: 15)),
          const Spacer(),
          if (showMore)
            GestureDetector(
              onTap: onMore,
              child: Text(
                '查看更多',
                style: CommunityTheme.caption.copyWith(color: CommunityTheme.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostHit extends StatelessWidget {
  const _PostHit({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(result: post),
      child: AbsorbPointer(
        child: PostCardWidget(post: post),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.onTap});

  final TopicModel topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                topic.displayName,
                style: CommunityTheme.body.copyWith(fontSize: 16),
              ),
            ),
            Text(
              topic.heatLabel,
              style: CommunityTheme.caption.copyWith(
                color: CommunityTheme.labelTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onFollow});

  final CommunityUserHit user;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
                user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            backgroundColor: CommunityTheme.fillSecondary,
            child: user.avatar.isEmpty
                ? Icon(CupertinoIcons.person_fill,
                    color: CommunityTheme.labelTertiary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.nickname,
              style: CommunityTheme.body.copyWith(fontSize: 16),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            onPressed: onFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isFollowed
                    ? CommunityTheme.fillSecondary
                    : CommunityTheme.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                user.isFollowed ? '已关注' : '关注',
                style: TextStyle(
                  fontSize: 13,
                  color: user.isFollowed
                      ? CommunityTheme.labelSecondary
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CommunityTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CommunityTheme.separator, width: 0.5),
        ),
        child: Text(label, style: CommunityTheme.caption),
      ),
    );
  }
}
