import 'package:flutter/material.dart';
import 'package:module_utils/player/models/short_video_models.dart';

/// Mock 弹幕层（P0：循环划过动画）。
class DanmakuMockLayer extends StatefulWidget {
  const DanmakuMockLayer({
    super.key,
    this.items = const [],
  });

  final List<DanmakuMockItem> items;

  @override
  State<DanmakuMockLayer> createState() => _DanmakuMockLayerState();
}

class _DanmakuMockLayerState extends State<DanmakuMockLayer> {
  static const _defaultItems = [
    DanmakuMockItem(text: '这车真不错！', topFactor: 0.18),
    DanmakuMockItem(text: '价格多少？', topFactor: 0.32, colorArgb: 0xFFFFD666),
    DanmakuMockItem(text: '到店试驾～', topFactor: 0.46),
  ];

  @override
  Widget build(BuildContext context) {
    final list = widget.items.isEmpty ? _defaultItems : widget.items;
    return IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < list.length; i++)
            _DanmakuTrack(
              key: ValueKey('${list[i].text}_$i'),
              item: list[i],
              delay: Duration(milliseconds: i * 2200),
            ),
        ],
      ),
    );
  }
}

class _DanmakuTrack extends StatefulWidget {
  const _DanmakuTrack({super.key, required this.item, required this.delay});

  final DanmakuMockItem item;
  final Duration delay;

  @override
  State<_DanmakuTrack> createState() => _DanmakuTrackState();
}

class _DanmakuTrackState extends State<_DanmakuTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.item.durationMs),
    );
    Future<void>.delayed(widget.delay, () {
      if (!mounted) return;
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;
        final x = width * (1.2 - _controller.value * 1.4);
        final y = MediaQuery.sizeOf(context).height * widget.item.topFactor;
        return Positioned(
          left: x,
          top: y,
          child: child!,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.item.text,
          style: TextStyle(
            color: Color(widget.item.colorArgb),
            fontSize: 14,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
          ),
        ),
      ),
    );
  }
}
