import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_community/community/widgets/rich_text_content_widget.dart';

/// 正文默认最多 3 行，超出可「全文」展开 / 「收起」折叠。
class ExpandTextWidget extends StatelessWidget {
  const ExpandTextWidget({super.key, required this.post});

  final PostModel post;

  static const maxCollapsedLines = 3;

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CommunityViewModel>();
    final expanded = vm.isExpanded(post.id);
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          height: 1.45,
        ) ??
        const TextStyle(fontSize: 16, height: 1.45);

    return LayoutBuilder(
      builder: (context, constraints) {
        final needsToggle = _exceedsMaxLines(
          text: post.content,
          style: baseStyle,
          maxWidth: constraints.maxWidth,
          maxLines: maxCollapsedLines,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichTextContentWidget(
              content: post.content,
              maxLines: expanded ? null : maxCollapsedLines,
            ),
            if (needsToggle)
              GestureDetector(
                onTap: () => vm.toggleExpanded(post.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    expanded ? '收起' : '全文',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static bool _exceedsMaxLines({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    if (text.trim().isEmpty || maxWidth <= 0) return false;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }
}
