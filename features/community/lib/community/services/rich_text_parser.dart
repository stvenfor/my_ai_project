import 'package:module_community/community/models/rich_segment.dart';

/// 将动态文案解析为 RichSegment 列表。
class RichTextParser {
  RichTextParser._();

  static final _pattern = RegExp(
    r'(@[\u4e00-\u9fa5A-Za-z0-9_]+|#[\u4e00-\u9fa5A-Za-z0-9_]+|https?://[^\s]+)',
  );

  static List<RichSegment> parse(String raw) {
    if (raw.isEmpty) return [const RichSegment(type: RichSegmentType.plain, text: '')];

    final segments = <RichSegment>[];
    var start = 0;

    for (final match in _pattern.allMatches(raw)) {
      if (match.start > start) {
        segments.add(RichSegment(
          type: RichSegmentType.plain,
          text: raw.substring(start, match.start),
        ));
      }

      final token = match.group(0)!;
      if (token.startsWith('@')) {
        segments.add(RichSegment(
          type: RichSegmentType.mention,
          text: token,
          payload: token.substring(1),
        ));
      } else if (token.startsWith('#')) {
        segments.add(RichSegment(
          type: RichSegmentType.hashtag,
          text: token,
          payload: token.substring(1),
        ));
      } else {
        segments.add(RichSegment(
          type: RichSegmentType.link,
          text: token,
          payload: token,
        ));
      }
      start = match.end;
    }

    if (start < raw.length) {
      segments.add(RichSegment(
        type: RichSegmentType.plain,
        text: raw.substring(start),
      ));
    }

    return segments.isEmpty
        ? [RichSegment(type: RichSegmentType.plain, text: raw)]
        : segments;
  }
}
