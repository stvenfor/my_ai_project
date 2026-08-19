enum RichSegmentType { plain, mention, hashtag, link }

class RichSegment {
  const RichSegment({
    required this.type,
    required this.text,
    this.payload,
  });

  final RichSegmentType type;
  final String text;
  final String? payload;
}
