import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_community/community/widgets/comment_preview_widget.dart';
import 'package:module_community/community/widgets/expand_text_widget.dart';
import 'package:module_community/community/widgets/image_grid_widget.dart';
import 'package:module_community/community/widgets/like_bar_widget.dart';
import 'package:module_community/community/widgets/user_info_widget.dart';
import 'package:module_community/community/widgets/video_card_widget.dart';
import 'package:module_common_ui/module_common_ui.dart';

class PostCardWidget extends StatefulWidget {
  const PostCardWidget({super.key, required this.post});

  final PostModel post;

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = Get.find<CommunityViewModel>();
    final post = widget.post;

    return Container(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: UserInfoWidget(post: post)),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 22),
                onPressed: () => _showMore(context, vm, post),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpandTextWidget(post: post),
          if (post.hasImages) ...[
            const SizedBox(height: 10),
            ImageGridWidget(images: post.images, postId: post.id),
          ],
          if (post.hasVideo) ...[
            const SizedBox(height: 10),
            VideoCardWidget(
              videoUrl: post.videoUrl!,
              coverUrl: post.videoCoverUrl,
            ),
          ],
          LikeBarWidget(post: post),
          CommentPreviewWidget(post: post),
        ],
      ),
    );
  }

  void _showMore(
    BuildContext context,
    CommunityViewModel vm,
    PostModel post,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制文案'),
              onTap: () {
                Get.back<void>();
                vm.copyPostContent(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('举报'),
              onTap: () {
                Get.back<void>();
                UiKitInitializer.toast('举报已提交');
              },
            ),
            if (post.isMine)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back<void>();
                  vm.deletePost(post.id);
                },
              ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
    );
  }
}
