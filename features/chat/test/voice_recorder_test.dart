import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_chat/chat/services/voice_recorder.dart';

void main() {
  test('VoiceRecording.pathForSdk prefixes file:// on Android only', () {
    const rec = VoiceRecording(
      localPath: '/tmp/im_voice_1.aac',
      durationSeconds: 3,
    );
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(rec.pathForSdk, 'file:///tmp/im_voice_1.aac');
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(rec.pathForSdk, '/tmp/im_voice_1.aac');
    debugDefaultTargetPlatformOverride = null;
  });
}
