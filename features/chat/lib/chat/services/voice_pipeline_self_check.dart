import 'dart:async';
import 'dart:io';

import 'package:module_chat/chat/services/voice_player.dart';
import 'package:module_chat/chat/services/voice_recorder.dart';
import 'package:module_utils/module_utils.dart';

/// Structured result of [VoicePipelineSelfCheck.run].
///
/// Stages map 1:1 to user-facing symptoms so the HITL loop stays red-capable.
enum VoiceCheckStage {
  permission,
  recordStart,
  recordStop,
  fileValid,
  play,
  ok,
}

class VoiceCheckReport {
  const VoiceCheckReport({
    required this.passed,
    required this.failedStage,
    required this.message,
    this.path,
    this.bytes,
    this.elapsedMs,
    this.error,
  });

  final bool passed;
  final VoiceCheckStage failedStage;
  final String message;
  final String? path;
  final int? bytes;
  final int? elapsedMs;
  final String? error;

  /// Matches toast / symptom strings the user already reported.
  String get symptomCode => switch (failedStage) {
        VoiceCheckStage.permission || VoiceCheckStage.recordStart =>
          'record_start_failed',
        VoiceCheckStage.recordStop || VoiceCheckStage.fileValid =>
          'record_file_invalid',
        VoiceCheckStage.play => 'play_failed',
        VoiceCheckStage.ok => 'ok',
      };

  @override
  String toString() =>
      'VoiceCheckReport(passed=$passed stage=$failedStage code=$symptomCode '
      'bytes=$bytes elapsedMs=$elapsedMs path=$path msg=$message err=$error)';
}

/// Device/mic acceptance probe — **no gesture race**, same recorder/player as chat.
///
/// Prints lines tagged `[DEBUG-voice]` (visible in `--release` via [print]).
class VoicePipelineSelfCheck {
  VoicePipelineSelfCheck({
    VoiceRecorder? recorder,
    VoicePlayer? player,
    this.recordMs = 1500,
  })  : _recorder = recorder ?? VoiceRecorder(),
        _player = player ?? VoicePlayer();

  final VoiceRecorder _recorder;
  final VoicePlayer _player;
  final int recordMs;

  static void _log(String msg) {
    // ignore: avoid_print — must survive --release (LogUtils.d may be stripped).
    print('[DEBUG-voice] $msg');
    LogUtils.w('[DEBUG-voice] $msg');
  }

  Future<VoiceCheckReport> run({bool playBack = true}) async {
    _log('probe begin recordMs=$recordMs playBack=$playBack');

    try {
      final okPerm = await _recorder.ensurePermission();
      _log('permission=$okPerm');
      if (!okPerm) {
        return const VoiceCheckReport(
          passed: false,
          failedStage: VoiceCheckStage.permission,
          message: '麦克风权限未授予',
        );
      }
    } catch (e) {
      _log('permission error=$e');
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.permission,
        message: '麦克风权限检查失败',
        error: '$e',
      );
    }

    final sw = Stopwatch()..start();
    try {
      await _recorder.start();
      _log('record start ok after ${sw.elapsedMilliseconds}ms');
    } catch (e, st) {
      _log('record start FAIL $e\n$st');
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.recordStart,
        message: '录音启动失败',
        error: '$e',
        elapsedMs: sw.elapsedMilliseconds,
      );
    }

    await Future<void>.delayed(Duration(milliseconds: recordMs));
    final holdMs = sw.elapsedMilliseconds;

    VoiceRecording? recording;
    try {
      recording = await _recorder.stop(
        durationSeconds: (holdMs / 1000).round().clamp(1, 60),
      );
    } catch (e, st) {
      _log('record stop THROW $e\n$st');
      await _recorder.cancel();
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.recordStop,
        message: '录音停止异常',
        error: '$e',
        elapsedMs: holdMs,
      );
    }

    if (recording == null) {
      _log('record stop returned null after ${holdMs}ms');
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.fileValid,
        message: '录音文件无效',
        elapsedMs: holdMs,
      );
    }

    final file = File(recording.localPath);
    final bytes = file.existsSync() ? file.lengthSync() : -1;
    _log('file path=${recording.localPath} bytes=$bytes duration=${recording.durationSeconds}');

    if (bytes < 100) {
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.fileValid,
        message: '录音文件无效',
        path: recording.localPath,
        bytes: bytes,
        elapsedMs: holdMs,
        error: 'bytes=$bytes',
      );
    }

    if (!playBack) {
      _log('probe PASS (skip play)');
      return VoiceCheckReport(
        passed: true,
        failedStage: VoiceCheckStage.ok,
        message: '录音验收通过',
        path: recording.localPath,
        bytes: bytes,
        elapsedMs: holdMs,
      );
    }

    try {
      await _player.play(recording.localPath);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await _player.stop();
      _log('play PASS');
    } catch (e, st) {
      _log('play FAIL $e\n$st');
      return VoiceCheckReport(
        passed: false,
        failedStage: VoiceCheckStage.play,
        message: '播放失败',
        path: recording.localPath,
        bytes: bytes,
        elapsedMs: holdMs,
        error: '$e',
      );
    }

    _log('probe PASS all stages');
    return VoiceCheckReport(
      passed: true,
      failedStage: VoiceCheckStage.ok,
      message: '录音+播放验收通过',
      path: recording.localPath,
      bytes: bytes,
      elapsedMs: holdMs,
    );
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
