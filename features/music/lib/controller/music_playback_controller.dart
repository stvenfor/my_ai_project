import 'package:get/get.dart';
import 'package:module_music/mock/music_mock_data.dart';
import 'package:module_music/model/local_song.dart';
import 'package:module_music/service/audio_player_service.dart';

/// 全局播放控制器（permanent），支持页面离开后继续播放。
class MusicPlaybackController extends GetxController {
  MusicPlaybackController({AudioPlayerService? audioService})
      : _audio = audioService ?? AudioPlayerService();

  final AudioPlayerService _audio;

  final songs = MusicMockData.songs.obs;
  final currentIndex = (-1).obs;
  final playerState = MusicPlayerState.stopped.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isMuted = false.obs;

  double _volumeBeforeMute = 1.0;
  bool _initialized = false;

  LocalSong? get currentSong {
    final index = currentIndex.value;
    if (index < 0 || index >= songs.length) return null;
    return songs[index];
  }

  bool get isPlaying => playerState.value == MusicPlayerState.playing;

  bool get hasActiveSession =>
      currentSong != null &&
      (playerState.value == MusicPlayerState.playing ||
          playerState.value == MusicPlayerState.paused);

  @override
  void onInit() {
    super.onInit();
    _bindAudioCallbacks();
  }

  @override
  void onClose() {
    _audio.dispose();
    super.onClose();
  }

  void _bindAudioCallbacks() {
    if (_initialized) return;
    _initialized = true;
    _audio.onDurationChanged = (value) => duration.value = value;
    _audio.onPositionChanged = (value) => position.value = value;
    _audio.onComplete = _onComplete;
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= songs.length) return;
    final song = songs[index];
    currentIndex.value = index;
    position.value = Duration.zero;
    duration.value = song.duration;
    playerState.value = MusicPlayerState.playing;
    await _audio.playUrl(song.audioUrl);
  }

  Future<void> togglePlayPause() async {
    if (currentSong == null) {
      await playAt(0);
      return;
    }
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    if (!isPlaying) return;
    await _audio.pause();
    playerState.value = MusicPlayerState.paused;
  }

  Future<void> resume() async {
    if (currentSong == null) return;
    await _audio.resume();
    playerState.value = MusicPlayerState.playing;
  }

  Future<void> stop() async {
    await _audio.stop();
    playerState.value = MusicPlayerState.stopped;
    position.value = Duration.zero;
    currentIndex.value = -1;
  }

  Future<void> seekTo(double milliseconds) async {
    final song = currentSong;
    if (song == null) return;
    final maxMs = duration.value.inMilliseconds > 0
        ? duration.value.inMilliseconds
        : song.duration.inMilliseconds;
    final clamped = milliseconds.clamp(0, maxMs.toDouble());
    final target = Duration(milliseconds: clamped.round());
    position.value = target;
    await _audio.seek(target);
  }

  Future<void> playNext() async {
    final next = currentIndex.value + 1;
    if (next >= songs.length) {
      await playAt(0);
    } else {
      await playAt(next);
    }
  }

  Future<void> playPrevious() async {
    final prev = currentIndex.value - 1;
    if (prev < 0) {
      await playAt(songs.length - 1);
    } else {
      await playAt(prev);
    }
  }

  Future<void> shuffleAndPlay() async {
    if (songs.isEmpty) return;
    final index = DateTime.now().millisecondsSinceEpoch % songs.length;
    await playAt(index);
  }

  Future<void> toggleMute() async {
    if (isMuted.value) {
      isMuted.value = false;
      await _audio.setVolume(_volumeBeforeMute);
    } else {
      _volumeBeforeMute = 1.0;
      isMuted.value = true;
      await _audio.setVolume(0);
    }
  }

  Future<void> _onComplete() async {
    await playNext();
  }

  static String formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class MusicPlaybackBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MusicPlaybackController>()) {
      Get.put(MusicPlaybackController(), permanent: true);
    }
  }
}
