import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_utils/module_utils.dart';

/// 会话语音播放（本地文件优先，其次远程 URL）。
///
/// 注意：不要在构造时抢 AVAudioSession，否则会把后续录音写成空文件。
class VoicePlayer {
  VoicePlayer({AudioPlayer? player}) : _injected = player;

  final AudioPlayer? _injected;
  AudioPlayer? _player;
  StreamSubscription<void>? _completeSub;
  bool _sessionReady = false;

  /// 当前条目播完时回调（用于停波动画）。
  void Function()? onComplete;

  static final AudioContext _session = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playAndRecord,
      options: {
        AVAudioSessionOptions.defaultToSpeaker,
        AVAudioSessionOptions.allowBluetooth,
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: false,
      contentType: AndroidContentType.speech,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  Future<AudioPlayer> _ensurePlayer() async {
    if (_player != null) return _player!;
    final p = _injected ?? AudioPlayer();
    await p.setPlayerMode(PlayerMode.mediaPlayer);
    _completeSub = p.onPlayerComplete.listen((_) => onComplete?.call());
    _player = p;
    return p;
  }

  Future<void> _ensureSession(AudioPlayer player) async {
    if (_sessionReady) return;
    try {
      await AudioPlayer.global.setAudioContext(_session);
      await player.setAudioContext(_session);
      _sessionReady = true;
    } catch (e) {
      LogUtils.w('[VoicePlayer] setAudioContext: $e');
    }
  }

  /// 从消息解析可播路径/URL；不可播返回 null。
  static String? resolveSource(MessageModel message) {
    String? strip(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return raw.replaceFirst(RegExp(r'^file://'), '');
    }

    final localCandidates = <String?>[
      strip(message.localPath),
      if (message.content.isNotEmpty &&
          !message.content.startsWith('http://') &&
          !message.content.startsWith('https://'))
        strip(message.content),
    ];
    for (final path in localCandidates) {
      if (path == null) continue;
      final f = File(path);
      if (f.existsSync() && f.lengthSync() > 0) return path;
    }

    final remote = message.remoteUrl?.trim();
    if (remote != null &&
        remote.isNotEmpty &&
        (remote.startsWith('http://') || remote.startsWith('https://'))) {
      return remote;
    }
    if (message.content.startsWith('http://') ||
        message.content.startsWith('https://')) {
      return message.content;
    }
    return null;
  }

  static String? _mimeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.m4a') || lower.endsWith('.mp4')) return 'audio/mp4';
    if (lower.endsWith('.aac')) return 'audio/aac';
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.amr')) return 'audio/amr';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    return null;
  }

  Future<void> play(String pathOrUrl) async {
    final player = await _ensurePlayer();
    await _ensureSession(player);

    final isRemote = pathOrUrl.startsWith('http://') ||
        pathOrUrl.startsWith('https://');
    LogUtils.d('[VoicePlayer] play $pathOrUrl');
    // ignore: avoid_print
    print('[DEBUG-voice] player.play $pathOrUrl');

    if (isRemote) {
      await player.play(UrlSource(pathOrUrl));
      return;
    }

    final path = pathOrUrl.replaceFirst(RegExp(r'^file://'), '');
    final file = File(path);
    if (!file.existsSync() || file.lengthSync() <= 0) {
      // ignore: avoid_print
      print('[DEBUG-voice] player missing file path=$path');
      throw StateError('voice_file_missing: $path');
    }

    final mime = _mimeForPath(path);
    // ignore: avoid_print
    print('[DEBUG-voice] player DeviceFileSource bytes=${file.lengthSync()} mime=$mime');
    try {
      await player.play(DeviceFileSource(path, mimeType: mime));
      // ignore: avoid_print
      print('[DEBUG-voice] player DeviceFileSource ok');
    } catch (e) {
      // ignore: avoid_print
      print('[DEBUG-voice] player DeviceFileSource FAIL $e');
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        LogUtils.w('[VoicePlayer] DeviceFileSource failed, retry UrlSource: $e');
        await player.play(UrlSource(Uri.file(path).toString(), mimeType: mime));
        // ignore: avoid_print
        print('[DEBUG-voice] player UrlSource ok');
        return;
      }
      rethrow;
    }
  }

  Future<void> stop() async {
    final player = _player;
    if (player == null) return;
    try {
      await player.stop();
    } catch (e) {
      LogUtils.w('[VoicePlayer] stop: $e');
    }
  }

  Future<void> dispose() async {
    await _completeSub?.cancel();
    _completeSub = null;
    onComplete = null;
    final player = _player;
    _player = null;
    if (player != null && _injected == null) {
      await player.dispose();
    }
  }
}
