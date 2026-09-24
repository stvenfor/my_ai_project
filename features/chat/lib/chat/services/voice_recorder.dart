import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:module_utils/module_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Holds a finished recording ready for RongCloud [createVoiceMessage].
class VoiceRecording {
  const VoiceRecording({
    required this.localPath,
    required this.durationSeconds,
  });

  /// Absolute filesystem path (no `file://` prefix).
  final String localPath;

  final int durationSeconds;

  /// Path RongCloud expects — Android needs a `file://` URI.
  String get pathForSdk {
    if (defaultTargetPlatform == TargetPlatform.android &&
        !localPath.startsWith('file://')) {
      return 'file://$localPath';
    }
    return localPath;
  }
}

/// AAC/M4A capture via `record` (iOS AVAudioRecorder → MPEG-4 AAC = `.m4a`).
class VoiceRecorder {
  VoiceRecorder({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _activePath;

  Future<bool> ensurePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    if (status.isGranted) return true;
    return _recorder.hasPermission();
  }

  Future<void> start() async {
    if (!await ensurePermission()) {
      throw StateError('microphone_permission_denied');
    }
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    // iOS aacLc → AVFileType.m4a；扩展名必须是 .m4a，用 .aac 会空文件。
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/im_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _activePath = path;

    // ignore: avoid_print
    print('[DEBUG-voice] recorder.start path=$path');

    // 对齐融云 example + record README。
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        bitRate: 32000,
        numChannels: 1,
      ),
      path: path,
    );

    final recording = await _recorder.isRecording();
    // ignore: avoid_print
    print('[DEBUG-voice] recorder.isRecording=$recording');
    if (!recording) {
      _activePath = null;
      throw StateError('recorder_not_recording');
    }
    LogUtils.d('[VoiceRecorder] started $path');
  }

  /// Stops recording. Returns null only if cancelled / nothing captured.
  Future<VoiceRecording?> stop({required int durationSeconds}) async {
    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      LogUtils.w('[VoiceRecorder] stop error: $e');
    }
    path ??= _activePath;
    _activePath = null;

    if (path == null || path.isEmpty) {
      // ignore: avoid_print
      print('[DEBUG-voice] recorder.stop empty path');
      LogUtils.w('[VoiceRecorder] stop: empty path');
      return null;
    }

    final file = File(path.replaceFirst(RegExp(r'^file://'), ''));
    // iOS 停录后文件可能略晚落盘。
    for (var i = 0; i < 15; i++) {
      if (file.existsSync() && file.lengthSync() > 44) break;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (!file.existsSync()) {
      // ignore: avoid_print
      print('[DEBUG-voice] recorder.stop missing path=$path');
      LogUtils.w('[VoiceRecorder] stop: file missing $path');
      return null;
    }
    final len = file.lengthSync();
    // ignore: avoid_print
    print('[DEBUG-voice] recorder.stop path=$path bytes=$len duration=$durationSeconds');
    // m4a header alone can be tiny; require some payload.
    if (len < 100) {
      LogUtils.w('[VoiceRecorder] stop: too small ($len bytes) $path');
      _tryDelete(path);
      return null;
    }

    LogUtils.d('[VoiceRecorder] stop ok bytes=$len duration=$durationSeconds');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return VoiceRecording(
      localPath: file.path,
      durationSeconds: durationSeconds.clamp(1, 60),
    );
  }

  Future<void> cancel() async {
    try {
      String? path;
      if (await _recorder.isRecording()) {
        path = await _recorder.stop();
      }
      path ??= _activePath;
      _activePath = null;
      if (path != null) _tryDelete(path);
    } catch (e) {
      LogUtils.w('[VoiceRecorder] cancel: $e');
      _activePath = null;
    }
  }

  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }

  void _tryDelete(String path) {
    try {
      final f = File(path.replaceFirst(RegExp(r'^file://'), ''));
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }
}
