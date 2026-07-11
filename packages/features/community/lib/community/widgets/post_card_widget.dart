import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/theme/community_theme.dart';
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

    return DecoratedBox(
      decoration: CommunityTheme.groupedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: UserInfoWidget(post: post)),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showMore(context, vm, post),
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      size: 20,
                      color: CommunityTheme.labelSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ExpandTextWidget(post: post),
            if (post.hasImages) ...[
              const SizedBox(height: 12),
              ImageGridWidget(images: post.images, postId: post.id),
            ],
            if (post.hasVideo) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(CommunityTheme.radiusMd),
                child: VideoCardWidget(
                  videoUrl: post.videoUrl!,
                  coverUrl: post.videoCoverUrl,
                ),
              ),
            ],
            LikeBarWidget(post: post),
            CommentPreviewWidget(post: post),
          ],
        ),
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
              leading: const Icon(CupertinoIcons.doc_on_doc),
              title: const Text('复制文案'),
              onTap: () {
                Get.back<void>();
                vm.copyPostContent(post);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.flag),
              title: const Text('举报'),
              onTap: () {
                Get.back<void>();
                UiKitInitializer.toast('举报已提交');
              },
            ),
            if (post.isMine)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.delete,
                  color: CommunityTheme.likeRed,
                ),
                title: const Text(
                  '删除',
                  style: TextStyle(color: CommunityTheme.likeRed),
                ),
                onTap: () {
                  Get.back<void>();
                  vm.deletePost(post.id);
                },
              ),
          ],
        ),
      ),
      backgroundColor: CommunityTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
    );
  }
}
