import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

typedef DurationChangedCallback = void Function(Duration duration);
typedef PositionChangedCallback = void Function(Duration position);
typedef PlaybackCompleteCallback = void Function();

/// audioplayers 封装，供 [MusicPlaybackController] 使用。
class AudioPlayerService {
  AudioPlayerService() {
    _player = AudioPlayer();
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _bindStreams();
  }

  late final AudioPlayer _player;
  DurationChangedCallback? onDurationChanged;
  PositionChangedCallback? onPositionChanged;
  PlaybackCompleteCallback? onComplete;

  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;

  /// 串行化原生播放操作，避免 iOS 切歌时 continuation 泄漏。
  Future<void> _operationChain = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() action) {
    final task = _operationChain.then((_) => action());
    _operationChain = task.catchError((_) {});
    return task;
  }

  void _bindStreams() {
    _durationSub = _player.onDurationChanged.listen((duration) {
      onDurationChanged?.call(duration);
    });
    _positionSub = _player.onPositionChanged.listen((position) {
      onPositionChanged?.call(position);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      onComplete?.call();
    });
  }

  Future<void> playUrl(String url) {
    // 不要先 stop()：iOS 会在 setUpPlayerItemStatusObservation 完成前 reset，
    // 触发 "continuation leaked without resuming" 运行时警告。
    return _enqueue(() => _player.play(UrlSource(url)));
  }

  Future<void> pause() => _enqueue(() => _player.pause());

  Future<void> resume() => _enqueue(() => _player.resume());

  Future<void> stop() => _enqueue(() => _player.stop());

  Future<void> seek(Duration position) => _enqueue(() => _player.seek(position));

  Future<void> setVolume(double volume) =>
      _enqueue(() => _player.setVolume(volume));

  Future<void> dispose() async {
    await _durationSub?.cancel();
    await _positionSub?.cancel();
    await _completeSub?.cancel();
    await _player.dispose();
  }
}
