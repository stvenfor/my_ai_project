import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
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
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
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
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _ActionButton(
            icon: ScaleTransition(
              scale: _scaleAnim,
              child: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: post.isLiked ? Colors.red : color,
              ),
            ),
            label: post.likeCount > 0 ? '${post.likeCount}' : '赞',
            color: post.isLiked ? Colors.red : color,
            onTap: () async {
              _heartController.forward(from: 0);
              await vm.toggleLike(post.id);
            },
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icon(Icons.chat_bubble_outline, size: 20, color: color),
            label: post.commentCount > 0 ? '${post.commentCount}' : '评论',
            color: color,
            onTap: () => vm.showCommentSheet(post),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}
