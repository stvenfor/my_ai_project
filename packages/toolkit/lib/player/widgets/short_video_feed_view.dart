import 'dart:async';

import 'package:flutter/material.dart';
import 'package:module_utils/player/core/video_network_watcher.dart';
import 'package:module_utils/player/core/video_player_pool.dart';
import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_utils/player/widgets/short_video_landscape_page.dart';
import 'package:module_utils/player/widgets/short_video_page_cell.dart';

/// 竖滑短视频 Feed。
class ShortVideoFeedView extends StatefulWidget {
  const ShortVideoFeedView({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.danmakuItems,
    this.overlayBuilder,
    this.onDoubleTapLike,
    this.onPlaybackEvent,
    this.physics,
  });

  final List<ShortVideoItem> items;
  final int initialIndex;
  final List<DanmakuMockItem>? danmakuItems;
  final ShortVideoOverlayBuilder? overlayBuilder;
  final ShortVideoIndexCallback? onDoubleTapLike;
  final ShortVideoPlaybackCallback? onPlaybackEvent;
  final ScrollPhysics? physics;

  @override
  State<ShortVideoFeedView> createState() => _ShortVideoFeedViewState();
}

class _ShortVideoFeedViewState extends State<ShortVideoFeedView>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final VideoPlayerPool _pool;
  late final VideoNetworkWatcher _networkWatcher;

  int _currentIndex = 0;
  int? _landscapeIndex;
  Duration _lastPosition = Duration.zero;
  String? _lastUrl;
  bool _wasPlaying = false;
  final _tickVersion = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pool = VideoPlayerPool();
    _networkWatcher = VideoNetworkWatcher();
    if (widget.items.isEmpty) {
      _pageController = PageController();
      return;
    }
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    _networkWatcher.start(
      onDisconnect: () => _pool.pauseAll(),
      onReconnect: _recoverPlayback,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _onPageSettled(_currentIndex));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _rememberPlayback();
      _pool.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      _onPageSettled(_currentIndex);
    }
  }

  void _rememberPlayback() {
    final controller = _pool.controllerAt(_currentIndex);
    if (controller == null) return;
    _lastPosition = controller.value.position;
    _lastUrl = widget.items[_currentIndex].url;
    _wasPlaying = controller.value.isPlaying;
  }

  Future<void> _recoverPlayback() async {
    final index = _currentIndex;
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    final url = _lastUrl ?? item.url;
    final position = _lastPosition;

    try {
      await _pool.activate(index, url);
      final controller = _pool.controllerAt(index);
      if (controller != null && position > Duration.zero) {
        await controller.seekTo(position);
      }
      if (_wasPlaying) {
        await controller?.play();
      }
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.networkReconnect,
          index: index,
          itemId: item.id,
          position: position,
        ),
      );
      _notifyTick();
    } catch (e) {
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.error,
          index: index,
          itemId: item.id,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPageSettled(int index) async {
    if (index < 0 || index >= widget.items.length) return;
    setState(() => _currentIndex = index);
    final item = widget.items[index];

    try {
      await _pool.activate(index, item.url);
      _lastUrl = item.url;
      _lastPosition = Duration.zero;
      _wasPlaying = true;

      unawaited(
        _pool.preloadNeighbors(index, (i) {
          if (i < 0 || i >= widget.items.length) return null;
          return widget.items[i].url;
        }),
      );

      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.play,
          index: index,
          itemId: item.id,
        ),
      );
    } catch (e) {
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.error,
          index: index,
          itemId: item.id,
          message: e.toString(),
        ),
      );
    }
    _notifyTick();
  }

  Future<void> _togglePlayPause() async {
    final controller = _pool.controllerAt(_currentIndex);
    if (controller == null) return;
    final item = widget.items[_currentIndex];
    if (controller.value.isPlaying) {
      await controller.pause();
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.pause,
          index: _currentIndex,
          itemId: item.id,
        ),
      );
    } else {
      await controller.play();
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.play,
          index: _currentIndex,
          itemId: item.id,
        ),
      );
    }
    _notifyTick();
  }

  void _notifyTick() {
    _tickVersion.value++;
    if (mounted) setState(() {});
  }

  Future<void> _openLandscape(
    BuildContext context,
    int index,
    ShortVideoItem item,
  ) async {
    var controller = _pool.controllerAt(index);
    if (controller == null || !_pool.isInitialized(index)) {
      controller = await _pool.prepare(index, item.url);
    }
    if (controller == null || !controller.value.isInitialized) {
      widget.onPlaybackEvent?.call(
        PlaybackEvent(
          type: PlaybackEventType.error,
          index: index,
          itemId: item.id,
          message: '视频尚未就绪，请稍后再试',
        ),
      );
      return;
    }

    setState(() => _landscapeIndex = index);
    _notifyTick();

    try {
      await ShortVideoLandscapePage.open(
        context,
        item: item,
        controller: controller,
      );
    } finally {
      if (!mounted) return;
      setState(() => _landscapeIndex = null);
      _notifyTick();
      if (index == _currentIndex &&
          controller.value.isInitialized &&
          !controller.value.isPlaying) {
        await controller.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _networkWatcher.dispose();
    _pool.disposeAll();
    _pageController.dispose();
    _tickVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('暂无视频'));
    }

    return ValueListenableBuilder<int>(
      valueListenable: _tickVersion,
      builder: (context, _, __) {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: widget.physics ?? const PageScrollPhysics(),
          itemCount: widget.items.length,
          onPageChanged: _onPageSettled,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final controller = _pool.controllerAt(index);
            final initialized = _pool.isInitialized(index);
            return ShortVideoPageCell(
              index: index,
              item: item,
              isActive: index == _currentIndex,
              controller: controller,
              initialized: initialized,
              hideVideoSurface: _landscapeIndex == index,
              danmakuItems: widget.danmakuItems,
              overlayBuilder: widget.overlayBuilder,
              onDoubleTapLike: () => widget.onDoubleTapLike?.call(index),
              onPlaybackEvent: widget.onPlaybackEvent,
              onTogglePlayPause: _togglePlayPause,
              onRequestFullscreen: index == _currentIndex
                  ? () => _openLandscape(context, index, item)
                  : null,
            );
          },
        );
      },
    );
  }
}
