import 'package:flutter_test/flutter_test.dart';
import 'package:module_http/sse/sse_frame.dart';
import 'package:module_http/sse/sse_parser.dart';

void main() {
  group('SseParser', () {
    test('parses meta / delta / done frames', () {
      const raw = 'event: meta\n'
          'data: {"type":"meta","conversationId":"c1"}\n'
          '\n'
          'event: delta\n'
          'data: {"type":"delta","text":"你好"}\n'
          '\n'
          'event: done\n'
          'data: {"type":"done","finishReason":"stop"}\n'
          '\n';

      final parser = SseParser();
      final frames = parser.add(raw).toList();

      expect(frames, hasLength(3));
      expect(frames[0].event, 'meta');
      expect(frames[0].data, contains('conversationId'));
      expect(frames[1].event, 'delta');
      expect(frames[1].data, contains('你好'));
      expect(frames[2].event, 'done');
    });

    test('ignores keepalive comment lines', () {
      const raw = ': keepalive\n'
          '\n'
          'event: delta\n'
          'data: {"text":"a"}\n'
          '\n'
          ': keepalive\n'
          '\n';

      final frames = SseParser().add(raw).toList();
      expect(frames, hasLength(1));
      expect(frames.single.event, 'delta');
      expect(frames.single.data, '{"text":"a"}');
    });

    test('buffers incomplete lines across chunks', () {
      final parser = SseParser();
      final first = parser.add('event: del').toList();
      expect(first, isEmpty);

      final second = parser.add('ta\ndata: {"t":"x"}\n\n').toList();
      expect(second, hasLength(1));
      expect(second.single.event, 'delta');
      expect(second.single.data, '{"t":"x"}');
    });

    test('joins multi-line data with newline', () {
      const raw = 'event: message\n'
          'data: line1\n'
          'data: line2\n'
          '\n';
      final frames = SseParser().add(raw).toList();
      expect(frames.single.data, 'line1\nline2');
    });

    test('flush does not emit incomplete field state without blank line', () {
      final parser = SseParser();
      expect(parser.add('event: delta\ndata: oops').toList(), isEmpty);
      expect(parser.flush().toList(), isEmpty);
    });

    test('supports CRLF line endings', () {
      const raw = 'event: delta\r\ndata: {"text":"ok"}\r\n\r\n';
      final frames = SseParser().add(raw).toList();
      expect(frames, hasLength(1));
      expect(frames.single.data, '{"text":"ok"}');
    });

    test('captures optional id field', () {
      const raw = 'id: 42\n'
          'event: delta\n'
          'data: hi\n'
          '\n';
      final frame = SseParser().add(raw).single;
      expect(frame.id, '42');
      expect(frame.event, 'delta');
    });
  });
}
