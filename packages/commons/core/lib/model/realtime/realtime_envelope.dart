/// 统一 WS Envelope（含 ping/pong/auth/event）。
class RealtimeEnvelope {
  const RealtimeEnvelope({
    this.id,
    required this.type,
    this.topic,
    this.ts,
    this.seq,
    this.payload = const {},
    this.raw = const {},
  });

  final String? id;
  final String type;
  final String? topic;
  final int? ts;
  final int? seq;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> raw;

  String? get eventName => payload['name'] as String?;

  bool get isControl => switch (type) {
        'ping' || 'pong' || 'auth' || 'auth_ok' || 'ack' || 'error' || 'sub' || 'unsub' => true,
        _ => false,
      };

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type,
        if (topic != null) 'topic': topic,
        if (ts != null) 'ts': ts,
        if (seq != null) 'seq': seq,
        'payload': payload,
      };

  factory RealtimeEnvelope.fromJson(Map<String, dynamic> json) {
    final payloadRaw = json['payload'];
    return RealtimeEnvelope(
      id: json['id']?.toString(),
      type: json['type']?.toString() ?? 'unknown',
      topic: json['topic']?.toString(),
      ts: _asInt(json['ts']),
      seq: _asInt(json['seq']),
      payload: payloadRaw is Map
          ? Map<String, dynamic>.from(payloadRaw)
          : const {},
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
