import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/services/voice_player.dart';

void main() {
  test('resolveSource prefers existing local file over remote', () {
    final file = File('${Directory.systemTemp.path}/im_voice_play_test.m4a')
      ..writeAsBytesSync(List<int>.filled(200, 1));
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    final msg = MessageModel(
      id: '1',
      conversationId: 'c',
      type: MessageType.voice,
      content: file.path,
      isSelf: true,
      createdAt: DateTime.now(),
      localPath: 'file://${file.path}',
      remoteUrl: 'https://example.com/a.m4a',
      voiceDurationSeconds: 3,
    );

    expect(VoicePlayer.resolveSource(msg), file.path);
  });

  test('resolveSource falls back to https remote when local missing', () {
    final msg = MessageModel(
      id: '2',
      conversationId: 'c',
      type: MessageType.voice,
      content: '',
      isSelf: false,
      createdAt: DateTime.now(),
      localPath: '/tmp/does_not_exist_voice.m4a',
      remoteUrl: 'https://cdn.example.com/v.m4a',
      voiceDurationSeconds: 2,
    );

    expect(VoicePlayer.resolveSource(msg), 'https://cdn.example.com/v.m4a');
  });

  test('resolveSource returns null when nothing playable', () {
    final msg = MessageModel(
      id: '3',
      conversationId: 'c',
      type: MessageType.voice,
      content: '',
      isSelf: true,
      createdAt: DateTime.now(),
    );
    expect(VoicePlayer.resolveSource(msg), isNull);
  });
}
