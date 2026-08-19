import 'dart:async';
import 'dart:collection';

import 'package:module_core/service/im_backup_service.dart';
import 'package:module_utils/module_utils.dart';

/// 聊天记录备份 Mock 队列。
class MockImBackupService implements ImBackupService {
  final Queue<_BackupItem> _pending = Queue();

  @override
  Future<void> backupOutbound({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required String type,
    required Map<String, dynamic> payload,
    required DateTime sentAt,
  }) async {
    await _enqueue(
      _BackupItem(
        direction: 'out',
        imUserId: imUserId,
        conversationId: conversationId,
        messageUid: messageUid,
        type: type,
        payload: payload,
        sentAt: sentAt,
      ),
    );
  }

  @override
  Future<void> backupInbound({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required String type,
    required Map<String, dynamic> payload,
    required DateTime sentAt,
  }) async {
    await _enqueue(
      _BackupItem(
        direction: 'in',
        imUserId: imUserId,
        conversationId: conversationId,
        messageUid: messageUid,
        type: type,
        payload: payload,
        sentAt: sentAt,
      ),
    );
  }

  @override
  Future<void> backupRecall({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required DateTime recalledAt,
  }) async {
    LogUtils.i(
      '[ImBackup] mock recall imUserId=$imUserId conv=$conversationId uid=$messageUid',
    );
  }

  Future<void> _enqueue(_BackupItem item) async {
    _pending.addLast(item);
    LogUtils.i('[ImBackup] queued ${item.direction} ${item.type} uid=${item.messageUid}');
    if (_pending.length >= 5) {
      await flushPending();
    }
  }

  @override
  Future<void> flushPending() async {
    while (_pending.isNotEmpty) {
      final item = _pending.removeFirst();
      LogUtils.i('[ImBackup] mock POST /im/messages/backup $item');
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
  }

  int get pendingCount => _pending.length;
}

class _BackupItem {
  _BackupItem({
    required this.direction,
    required this.imUserId,
    required this.conversationId,
    required this.messageUid,
    required this.type,
    required this.payload,
    required this.sentAt,
  });

  final String direction;
  final String imUserId;
  final String conversationId;
  final String messageUid;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime sentAt;

  @override
  String toString() =>
      '$direction/$type conv=$conversationId uid=$messageUid at=$sentAt';
}
