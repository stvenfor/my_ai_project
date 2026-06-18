import 'dart:convert';

import 'package:module_global_cache/db/app_database.dart';
import 'package:uuid/uuid.dart';

/// 离线 outbound 持久化队列。
class OutboundQueueManager {
  OutboundQueueManager({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  final _uuid = const Uuid();

  int _depth = 0;

  int get depth => _depth;

  Future<String> enqueue({
    required String topic,
    required String eventName,
    Map<String, dynamic>? payload,
  }) async {
    final messageId = _uuid.v4();
    await _database.upsertOutbound(
      messageId: messageId,
      topic: topic,
      eventName: eventName,
      payloadJson: jsonEncode(payload ?? {}),
      status: 'pending',
    );
    _depth++;
    return messageId;
  }

  Future<void> markSent(String messageId) async {
    await _database.updateOutboundStatus(messageId, 'sent');
  }

  Future<void> markAcked(String messageId) async {
    await _database.deleteOutbound(messageId);
    _depth = (_depth - 1).clamp(0, 9999);
  }

  Future<void> markFailed(String messageId) async {
    await _database.updateOutboundStatus(messageId, 'failed');
  }

  Future<List<OutboundQueueItem>> pendingItems() async {
    final rows = await _database.pendingOutbound();
    _depth = rows.length;
    return rows.map(OutboundQueueItem.fromRow).toList();
  }

  Future<void> clear() async {
    await _database.clearOutbound();
    _depth = 0;
  }

  Future<void> refreshDepth() async {
    final rows = await _database.pendingOutbound();
    _depth = rows.length;
  }
}

class OutboundQueueItem {
  const OutboundQueueItem({
    required this.messageId,
    required this.topic,
    required this.eventName,
    required this.payloadJson,
    required this.status,
  });

  final String messageId;
  final String topic;
  final String eventName;
  final String payloadJson;
  final String status;

  Map<String, dynamic> decodePayload() {
    try {
      return jsonDecode(payloadJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  factory OutboundQueueItem.fromRow(Map<String, dynamic> row) {
    return OutboundQueueItem(
      messageId: row['message_id'] as String,
      topic: row['topic'] as String,
      eventName: row['event_name'] as String,
      payloadJson: row['payload_json'] as String,
      status: row['status'] as String,
    );
  }
}
