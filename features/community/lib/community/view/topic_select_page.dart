import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';

/// 关联话题选择页。
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
      final list = q.isEmpty
          ? await repo.fetchTopics()
          : await repo.searchTopics(q);
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '关联话题', showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _query,
              decoration: InputDecoration(
                hintText: '搜索话题',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
              onChanged: (_) {
                // 轻量：停顿感由用户点搜索/回车；短列表直接刷新
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _topics.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = _topics[index];
                      final selected = t.id == widget.selectedId;
                      return ListTile(
                        leading: Icon(
                          t.isAskEveryone ? Icons.help_outline : Icons.tag,
                          color: t.isAskEveryone ? Colors.blue : Colors.grey,
                        ),
                        title: Text(t.displayName),
                        subtitle: t.isAskEveryone
                            ? const Text('关联后将邀请相关盘友回答')
                            : Text(t.heatLabel),
                        trailing: selected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () => Get.back(result: t),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
