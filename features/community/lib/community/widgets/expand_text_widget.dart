import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_community/community/widgets/rich_text_content_widget.dart';

class ExpandTextWidget extends StatelessWidget {
  const ExpandTextWidget({super.key, required this.post});

  final PostModel post;

  static const maxCollapsedLines = 3;

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CommunityViewModel>();
    final expanded = vm.isExpanded(post.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
          firstChild: RichTextContentWidget(
            content: post.content,
            maxLines: maxCollapsedLines,
          ),
          secondChild: RichTextContentWidget(content: post.content),
        ),
        if (_needsToggle(post.content))
          GestureDetector(
            onTap: () => vm.toggleExpanded(post.id),
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
  }

  bool _needsToggle(String text) {
    if (text.length < 60) return false;
    return text.contains('\n') || text.length > 80;
  }
}
