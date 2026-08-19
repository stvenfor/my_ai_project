import 'dart:async';

import 'package:video_player/video_player.dart';

class _PoolSlot {
  _PoolSlot({
    required this.index,
    required this.url,
    required this.controller,
    required this.generation,
  });

  final int index;
  final String url;
  final VideoPlayerController controller;
  final int generation;
  bool initialized = false;
  bool disposed = false;
  String? errorMessage;
}

/// 播放器池：保留当前页及相邻页，仅 initialize 预加载，不自动 play。
class VideoPlayerPool {
  VideoPlayerPool({this.keepRadius = 1});

  final int keepRadius;
  final Map<int, _PoolSlot> _slots = {};
  int _generation = 0;
  int? _activeIndex;

  int? get activeIndex => _activeIndex;

  VideoPlayerController? controllerAt(int index) => _slots[index]?.controller;

  bool isInitialized(int index) =>
      _slots[index]?.initialized == true && _slots[index]?.disposed == false;

  String? errorAt(int index) => _slots[index]?.errorMessage;

  void clearError(int index) {
    final slot = _slots[index];
    if (slot != null) slot.errorMessage = null;
  }

  /// 预加载或获取指定 index 的控制器（不播放）。
  Future<VideoPlayerController?> prepare(int index, String url) async {
    final existing = _slots[index];
    if (existing != null && existing.url == url && !existing.disposed) {
      if (!existing.initialized) {
        await _initializeSlot(existing);
      }
      return existing.controller;
    }

    await _disposeSlot(index);

    final gen = ++_generation;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    final slot = _PoolSlot(
      index: index,
      url: url,
      controller: controller,
      generation: gen,
    );
    _slots[index] = slot;

    await _initializeSlot(slot);
    if (slot.generation != gen || slot.disposed) {
      return null;
    }
    return controller;
  }

  Future<void> _initializeSlot(_PoolSlot slot) async {
    if (slot.initialized || slot.disposed) return;
    slot.errorMessage = null;
    try {
      await slot.controller.initialize();
      await slot.controller.setLooping(true);
      if (_activeIndex != slot.index) {
        await slot.controller.setVolume(0);
      }
      slot.initialized = true;
    } catch (e) {
      slot.initialized = false;
      slot.errorMessage = e.toString();
      rethrow;
    }
  }

  /// 激活页：恢复音量并播放，其余暂停。
  Future<void> activate(int index, String url) async {
    _activeIndex = index;
    trimExcept(index);

    final controller = await prepare(index, url);
    if (controller == null) return;

    await controller.setVolume(1);
    if (!controller.value.isPlaying) {
      await controller.play();
    }

    for (final entry in _slots.entries) {
      if (entry.key == index) continue;
      if (entry.value.controller.value.isPlaying) {
        await entry.value.controller.pause();
      }
    }
  }

  Future<void> pauseAll() async {
    for (final slot in _slots.values) {
      if (!slot.disposed && slot.controller.value.isPlaying) {
        await slot.controller.pause();
      }
    }
  }

  Future<void> pause(int index) async {
    final slot = _slots[index];
    if (slot == null || slot.disposed) return;
    if (slot.controller.value.isPlaying) {
      await slot.controller.pause();
    }
  }

  /// 预加载相邻页（仅 init）。
  Future<void> preloadNeighbors(
    int currentIndex,
    String? Function(int index) urlAt,
  ) async {
    for (var offset = -keepRadius; offset <= keepRadius; offset++) {
      if (offset == 0) continue;
      final i = currentIndex + offset;
      if (i < 0) continue;
      final url = urlAt(i);
      if (url == null || url.isEmpty) continue;
      unawaited(prepare(i, url).catchError((_) => null as VideoPlayerController?));
    }
  }

  void trimExcept(int center) {
    final keys = _slots.keys.toList();
    for (final index in keys) {
      if ((index - center).abs() > keepRadius) {
        unawaited(_disposeSlot(index));
      }
    }
  }

  Future<void> _disposeSlot(int index) async {
    final slot = _slots.remove(index);
    if (slot == null || slot.disposed) return;
    slot.disposed = true;
    try {
      await slot.controller.pause();
      await slot.controller.dispose();
    } catch (_) {}
  }

  Future<void> disposeAll() async {
    final keys = _slots.keys.toList();
    for (final index in keys) {
      await _disposeSlot(index);
    }
    _activeIndex = null;
  }
}
