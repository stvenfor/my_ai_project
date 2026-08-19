import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

/// 短视频手势：单击/双击/长按倍速/左右半屏亮度音量/横拖进度。
class ShortVideoGestureHandler extends StatefulWidget {
  const ShortVideoGestureHandler({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSingleTap,
    required this.onDoubleTap,
    required this.onSeek,
  });

  final VideoPlayerController controller;
  final bool enabled;
  final VoidCallback onSingleTap;
  final VoidCallback onDoubleTap;
  final void Function(Duration position) onSeek;

  @override
  State<ShortVideoGestureHandler> createState() =>
      _ShortVideoGestureHandlerState();
}

class _ShortVideoGestureHandlerState extends State<ShortVideoGestureHandler> {
  static const _doubleTapWindow = Duration(milliseconds: 280);

  Timer? _tapTimer;
  int _tapCount = 0;
  bool _longPressing = false;
  bool _horizontalDragging = false;
  bool _showProgress = false;
  double _dragProgress = 0;
  double? _brightness;
  double? _volume;
  Offset? _dragStart;

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  void _handleTapUp() {
    _tapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(_doubleTapWindow, () {
      if (!mounted) return;
      if (_tapCount >= 2) {
        widget.onDoubleTap();
      } else {
        widget.onSingleTap();
      }
      _tapCount = 0;
    });
  }

  Future<void> _onLongPressStart() async {
    if (!widget.enabled) return;
    _longPressing = true;
    await widget.controller.setPlaybackSpeed(2);
  }

  Future<void> _onLongPressEnd() async {
    if (!_longPressing) return;
    _longPressing = false;
    await widget.controller.setPlaybackSpeed(1);
  }

  void _hideProgressLater() {
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_horizontalDragging) {
        setState(() => _showProgress = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: widget.enabled ? (_) => _handleTapUp() : null,
          onLongPressStart: widget.enabled ? (_) => _onLongPressStart() : null,
          onLongPressEnd: widget.enabled ? (_) => _onLongPressEnd() : null,
          onLongPressCancel: widget.enabled ? _onLongPressEnd : null,
          onVerticalDragStart: widget.enabled ? _onVerticalDragStart : null,
          onVerticalDragUpdate: widget.enabled ? _onVerticalDragUpdate : null,
          onVerticalDragEnd: widget.enabled ? _onVerticalDragEnd : null,
          onHorizontalDragStart: widget.enabled ? _onHorizontalDragStart : null,
          onHorizontalDragUpdate: widget.enabled ? _onHorizontalDragUpdate : null,
          onHorizontalDragEnd: widget.enabled ? _onHorizontalDragEnd : null,
          child: const SizedBox.expand(),
        ),
        if (_showProgress) _ProgressOverlay(progress: _dragProgress),
        if (_brightness != null) _SideHud(icon: Icons.brightness_6, value: _brightness!),
        if (_volume != null) _SideHud(icon: Icons.volume_up, value: _volume!),
      ],
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    final width = MediaQuery.sizeOf(context).width;
    if (details.localPosition.dx < width / 2) {
      ScreenBrightness.instance.application.then((v) => _brightness = v);
    } else {
      VolumeController.instance.getVolume().then((v) => _volume = v);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final start = _dragStart;
    if (start == null) return;
    final width = MediaQuery.sizeOf(context).height;
    final delta = -details.localPosition.dy + start.dy;
    final change = delta / width;

    if (start.dx < MediaQuery.sizeOf(context).width / 2) {
      final base = _brightness ?? 0.5;
      final next = (base + change).clamp(0.0, 1.0);
      _brightness = next;
      ScreenBrightness.instance.setApplicationScreenBrightness(next);
    } else {
      final base = _volume ?? 0.5;
      final next = (base + change).clamp(0.0, 1.0);
      _volume = next;
      VolumeController.instance.setVolume(next);
    }
    setState(() {});
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragStart = null;
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _brightness = null;
          _volume = null;
        });
      }
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    final duration = widget.controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    _horizontalDragging = true;
    final pos = widget.controller.value.position;
    _dragProgress = pos.inMilliseconds / duration.inMilliseconds;
    setState(() => _showProgress = true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final duration = widget.controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final width = MediaQuery.sizeOf(context).width;
    _dragProgress = (_dragProgress + details.delta.dx / width).clamp(0.0, 1.0);
    setState(() {});
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    final duration = widget.controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final target = Duration(
      milliseconds: (duration.inMilliseconds * _dragProgress).round(),
    );
    await widget.controller.seekTo(target);
    widget.onSeek(target);
    _horizontalDragging = false;
    setState(() {});
    _hideProgressLater();
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideHud extends StatelessWidget {
  const _SideHud({required this.icon, required this.value});

  final IconData icon;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
