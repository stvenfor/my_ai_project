import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_utils/module_utils.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key, required this.post});

  final PostModel post;

  static Future<void> show(PostModel post) {
    return Get.bottomSheet<void>(
      CommentBottomSheet(post: post),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _inputController = TextEditingController();
  final _comments = <CommentModel>[].obs;
  final _loading = true.obs;
  String? _replyTo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _loading.value = true;
    final vm = Get.find<CommunityViewModel>();
    _comments.assignAll(await vm.loadComments(widget.post.id));
    _loading.value = false;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final vm = Get.find<CommunityViewModel>();
    await vm.sendComment(
      postId: widget.post.id,
      content: text,
      replyToNickname: _replyTo,
    );
    _inputController.clear();
    _replyTo = null;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '评论 ${widget.post.commentCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (_loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (_comments.isEmpty) {
                    return const Center(child: Text('暂无评论，快来抢沙发'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return ListTile(
                        leading: CacheImageUtils.circle(c.avatar, size: 36),
                        title: Text(c.nickname,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          c.replyToNickname != null
                              ? '回复 ${c.replyToNickname}：${c.content}'
                              : c.content,
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            _replyTo = c.nickname;
                            setState(() {});
                          },
                          child: const Text('回复'),
                        ),
                      );
                    },
                  );
                }),
              ),
              _buildInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: _replyTo != null ? '回复 $_replyTo' : '写评论…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _send,
              icon: const Icon(Icons.send, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
