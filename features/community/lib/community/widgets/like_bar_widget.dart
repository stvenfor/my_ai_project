import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/theme/community_theme.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:wys_login_share_pay/wys_login_share_pay.dart';

class LikeBarWidget extends StatefulWidget {
  const LikeBarWidget({super.key, required this.post});

  final PostModel post;

  @override
  State<LikeBarWidget> createState() => _LikeBarWidgetState();
}

class _LikeBarWidgetState extends State<LikeBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CommunityViewModel>();
    final post = widget.post;
    final defaultColor = CommunityTheme.labelSecondary;

    // 与媒体/正文的间距由 PostCard 统一控制（12），此处不再额外 top padding。
    return Row(
      children: [
        _ActionButton(
          icon: ScaleTransition(
            scale: _scaleAnim,
            child: Icon(
              post.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              size: 20,
              color: post.isLiked ? CommunityTheme.likeRed : defaultColor,
            ),
          ),
          label: post.likeCount > 0 ? '${post.likeCount}' : '赞',
          color: post.isLiked ? CommunityTheme.likeRed : defaultColor,
          onTap: () async {
            _heartController.forward(from: 0);
            await vm.toggleLike(post.id);
          },
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: Icon(
            CupertinoIcons.chat_bubble,
            size: 20,
            color: defaultColor,
          ),
          label: post.commentCount > 0 ? '${post.commentCount}' : '评论',
          color: defaultColor,
          onTap: () => vm.showCommentSheet(post),
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: Icon(
            CupertinoIcons.arrowshape_turn_up_right,
            size: 20,
            color: defaultColor,
          ),
          label: '分享',
          color: defaultColor,
          onTap: () => _sharePost(context, post),
        ),
      ],
    );
  }

  Future<void> _sharePost(BuildContext context, PostModel post) async {
    if (!WysWechatConfig.isConfigured) {
      UiKitInitializer.toast('请先在 WysWechatConfig 填写微信 AppID / Universal Link');
      return;
    }
    final scene = await showCupertinoModalPopup<WysWechatScene>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('分享到微信'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, WysWechatScene.session),
            child: const Text('微信好友'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, WysWechatScene.timeline),
            child: const Text('朋友圈'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (scene == null) return;

    final title = post.nickname.isNotEmpty ? '${post.nickname}的动态' : '社区动态';
    final desc = post.content.trim().isEmpty
        ? '来自 App 社区'
        : (post.content.length > 60
            ? '${post.content.substring(0, 60)}…'
            : post.content);
    final thumb = post.images.isNotEmpty
        ? post.images.first
        : (post.videoCoverUrl ?? '');
    // 网页分享需公网 URL；落地页未就绪前用占位，换正式 H5 时只改这里。
    final url = 'https://xiaomaomain.com/app/community/posts/${post.id}';

    final result = await WysWechatService.instance.shareWebpage(
      title: title,
      description: desc,
      webpageUrl: url,
      thumbUrl: thumb,
      scene: scene,
    );
    if (result.isSuccess) {
      UiKitInitializer.toast(
        scene == WysWechatScene.timeline ? '已唤起朋友圈' : '已唤起微信好友',
      );
    } else if (result.status == WysWechatStatus.notInstalled) {
      UiKitInitializer.toast('未安装微信');
    } else {
      UiKitInitializer.toast(result.message ?? '分享失败');
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
