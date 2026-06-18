/// 聊天记录备份（业务库），Mock 阶段仅日志 + 队列。
abstract class ImBackupService {
  Future<void> backupOutbound({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required String type,
    required Map<String, dynamic> payload,
    required DateTime sentAt,
  });

  Future<void> backupInbound({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required String type,
    required Map<String, dynamic> payload,
    required DateTime sentAt,
  });

  Future<void> backupRecall({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required DateTime recalledAt,
  });

  Future<void> flushPending();
}
