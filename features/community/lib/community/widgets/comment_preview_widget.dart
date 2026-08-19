import 'package:flutter/material.dart';
import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/post_model.dart';

class CommentPreviewWidget extends StatelessWidget {
  const CommentPreviewWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    if (post.previewComments.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: post.previewComments.map((c) => _line(context, c)).toList(),
      ),
    );
  }

  Widget _line(BuildContext context, CommentModel c) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final prefix = c.replyToNickname != null
        ? '${c.nickname} 回复 ${c.replyToNickname}：'
        : '${c.nickname}：';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, height: 1.35, color: onSurface),
          children: [
            TextSpan(
              text: prefix,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF576B95),
              ),
            ),
            TextSpan(text: c.content),
          ],
        ),
      ),
    );
  }
}
