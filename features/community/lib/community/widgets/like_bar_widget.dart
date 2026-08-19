import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/theme/community_theme.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';

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

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
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
            onTap: () {},
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
