import 'sse_frame.dart';

/// 增量 SSE 行协议解析器：喂入文本片段，在完整帧（空行）时产出 [SseFrame]。
///
/// - 忽略以 `:` 开头的注释行（含 keepalive）
/// - 同帧多行 `data:` 用 `\n` 拼接
/// - 残缺行保留在内部缓冲，直至下一次 [add] / [flush]
class SseParser {
  final StringBuffer _carry = StringBuffer();
  String? _event;
  final List<String> _dataLines = <String>[];
  String? _id;

  /// 追加一段已解码文本，返回本段内完成的帧。
  Iterable<SseFrame> add(String chunk) sync* {
    if (chunk.isEmpty) return;
    _carry.write(chunk);
    yield* _drainCompleteLines(flushRemainder: false);
  }

  /// 流结束时调用：尽量消费残留缓冲（无末尾换行的最后一行）。
  Iterable<SseFrame> flush() sync* {
    yield* _drainCompleteLines(flushRemainder: true);
    // 未以空行结束的半截字段丢弃，避免把残缺 JSON 当成完整帧。
    _resetFieldState();
  }

  Iterable<SseFrame> _drainCompleteLines({required bool flushRemainder}) sync* {
    var buffer = _carry.toString();
    _carry.clear();

    while (true) {
      final nl = buffer.indexOf('\n');
      if (nl < 0) {
        if (flushRemainder && buffer.isNotEmpty) {
          yield* _handleLine(_stripCr(buffer));
          buffer = '';
        }
        break;
      }
      final line = _stripCr(buffer.substring(0, nl));
      buffer = buffer.substring(nl + 1);
      yield* _handleLine(line);
    }

    if (buffer.isNotEmpty) {
      _carry.write(buffer);
    }
  }

  Iterable<SseFrame> _handleLine(String line) sync* {
    if (line.isEmpty) {
      final frame = _emitIfReady();
      if (frame != null) yield frame;
      return;
    }

    if (line.startsWith(':')) {
      // 注释 / keepalive
      return;
    }

    final colon = line.indexOf(':');
    final field = colon < 0 ? line : line.substring(0, colon);
    var value = colon < 0 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) {
      value = value.substring(1);
    }

    switch (field) {
      case 'event':
        _event = value;
      case 'data':
        _dataLines.add(value);
      case 'id':
        _id = value;
      default:
        break;
    }
  }

  SseFrame? _emitIfReady() {
    if (_event == null && _dataLines.isEmpty && _id == null) {
      return null;
    }
    final frame = SseFrame(
      event: _event ?? 'message',
      data: _dataLines.join('\n'),
      id: _id,
    );
    _resetFieldState();
    return frame;
  }

  void _resetFieldState() {
    _event = null;
    _dataLines.clear();
    _id = null;
  }

  static String _stripCr(String line) {
    if (line.endsWith('\r')) {
      return line.substring(0, line.length - 1);
    }
    return line;
  }
}
