import 'package:flutter_test/flutter_test.dart';
import 'package:module_chat/chat/services/voice_pipeline_self_check.dart';

void main() {
  test('symptomCode maps fileValid → record_file_invalid (user toast)', () {
    const r = VoiceCheckReport(
      passed: false,
      failedStage: VoiceCheckStage.fileValid,
      message: '录音文件无效',
      bytes: 0,
    );
    expect(r.symptomCode, 'record_file_invalid');
  });

  test('symptomCode maps play → play_failed', () {
    const r = VoiceCheckReport(
      passed: false,
      failedStage: VoiceCheckStage.play,
      message: '播放失败',
      error: 'DarwinAudioError',
    );
    expect(r.symptomCode, 'play_failed');
  });

  test('ok stage → ok', () {
    const r = VoiceCheckReport(
      passed: true,
      failedStage: VoiceCheckStage.ok,
      message: '录音+播放验收通过',
      bytes: 4000,
    );
    expect(r.symptomCode, 'ok');
  });
}
