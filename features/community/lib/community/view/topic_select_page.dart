import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_community/community/theme/community_theme.dart';

/// 关联话题：搜索 + 置顶问大家卡 + 热度列表。
class TopicSelectPage extends StatefulWidget {
  const TopicSelectPage({super.key, this.selectedId});

  final String? selectedId;

  @override
  State<TopicSelectPage> createState() => _TopicSelectPageState();
}

class _TopicSelectPageState extends State<TopicSelectPage> {
  final _query = TextEditingController();
  List<TopicModel> _topics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = Get.find<PostRepository>();
      final q = _query.text.trim();
      final list =
          q.isEmpty ? await repo.fetchTopics() : await repo.searchTopics(q);
      if (!mounted) return;
      // 问大家置顶
      list.sort((a, b) {
        if (a.isAskEveryone == b.isAskEveryone) return 0;
        return a.isAskEveryone ? -1 : 1;
      });
      setState(() {
        _topics = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      UiKitInitializer.toastError('加载话题失败');
    }
  }

  TopicModel? get _askTopic {
    for (final t in _topics) {
      if (t.isAskEveryone) return t;
    }
    return null;
  }

  List<TopicModel> get _normalTopics =>
      _topics.where((t) => !t.isAskEveryone).toList();

  @override
  Widget build(BuildContext context) {
    final ask = _askTopic;
    return AppPageScaffold(
      navBar: const AppNavBar(title: '关联话题', showBackButton: true),
      backgroundColor: CommunityTheme.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _query,
              onSubmitted: (_) => _load(),
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: '搜索话题',
                hintStyle: const TextStyle(color: CommunityTheme.labelTertiary),
                prefixIcon: const Icon(
                  Icons.search,
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      if (ask != null) ...[
                        _AskEveryoneCard(
                          topic: ask,
                          selected: ask.id == widget.selectedId,
                          onTap: () => Get.back(result: ask),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ..._normalTopics.map((t) {
                        final selected = t.id == widget.selectedId;
                        return InkWell(
                          onTap: () => Get.back(result: t),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? CommunityTheme.accent
                                          : CommunityTheme.labelPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  t.heatLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: CommunityTheme.labelTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AskEveryoneCard extends StatelessWidget {
  const _AskEveryoneCard({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final TopicModel topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F3FF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF1677FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '#',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? CommunityTheme.accent
                            : CommunityTheme.labelPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '关联后将主动邀请相关持仓盘友回答问题',
                      style: TextStyle(
                        fontSize: 13,
                        color: CommunityTheme.labelSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: Color(0xFF1677FF), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
