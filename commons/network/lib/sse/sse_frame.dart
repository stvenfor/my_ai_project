/// 一条已完成的 SSE 逻辑帧（空行分隔后的 event/data/id）。
class SseFrame {
  const SseFrame({
    required this.event,
    required this.data,
    this.id,
  });

  /// `event:` 字段；未指定时为 `message`（WHATWG 默认）。
  final String event;

  /// 拼接后的 `data:` 载荷（多行 data 用 `\n` 连接）。
  final String data;

  /// 可选 `id:` 字段。
  final String? id;

  /// 注释行（如 `: keepalive`）解析后不会产出帧；此辅助仅便于测试命名。
  bool get isComment => false;

  @override
  String toString() => 'SseFrame(event: $event, data: $data, id: $id)';

  @override
  bool operator ==(Object other) {
    return other is SseFrame &&
        other.event == event &&
        other.data == data &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(event, data, id);
}
