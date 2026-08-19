import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/models/rich_segment.dart';
import 'package:module_community/community/services/rich_text_parser.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class RichTextContentWidget extends StatelessWidget {
  const RichTextContentWidget({
    super.key,
    required this.content,
    this.maxLines,
    this.style,
  });

  final String content;
  final int? maxLines;
  final TextStyle? style;

  static const _linkColor = Color(0xFF576B95);
  static const _tagColor = Color(0xFF576B95);

  @override
  Widget build(BuildContext context) {
    final segments = RichTextParser.parse(content);
    final baseStyle = style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              height: 1.45,
            ) ??
        const TextStyle(fontSize: 16, height: 1.45);

    return RichText(
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      text: TextSpan(
        style: baseStyle.copyWith(color: Theme.of(context).colorScheme.onSurface),
        children: segments.map((s) => _span(context, s, baseStyle)).toList(),
      ),
    );
  }

  TextSpan _span(BuildContext context, RichSegment segment, TextStyle base) {
    switch (segment.type) {
      case RichSegmentType.mention:
      case RichSegmentType.hashtag:
        return TextSpan(
          text: segment.text,
          style: base.copyWith(color: _tagColor, fontWeight: FontWeight.w500),
          recognizer: TapGestureRecognizer()
            ..onTap = () => UiKitInitializer.toast(
                  segment.type == RichSegmentType.mention
                      ? '用户主页：@${segment.payload}'
                      : '话题：#${segment.payload}',
                ),
        );
      case RichSegmentType.link:
        return TextSpan(
          text: segment.text,
          style: base.copyWith(color: _linkColor, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final url = segment.payload ?? segment.text;
              Get.toNamed(
                RoutePath.web,
                arguments: WebPageConfig.url(
                  url: url,
                  title: '链接',
                  showAppBar: true,
                ),
              );
            },
        );
      case RichSegmentType.plain:
        return TextSpan(text: segment.text);
    }
  }
}
