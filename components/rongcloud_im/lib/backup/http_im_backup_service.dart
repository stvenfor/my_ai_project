import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_core/service/im_backup_service.dart';

/// 真实备份：队列 + flush 到 BFF POST /api/v1/im/messages/backup。
class HttpImBackupService implements ImBackupService {
  final List<Map<String, dynamic>> _pending = [];

  @override
  Future<void> backupOutbound({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required String type,
    required Map<String, dynamic> payload,
    required DateTime sentAt,
  }) async {
    _pending.add({
      'message_uid': messageUid,
      'direction': 'out',
      'conversation_type': 'private',
      'target_id': conversationId,
      'message_type': type,
      'payload': payload,
      'sent_at': sentAt.toUtc().toIso8601String(),
    });
    if (_pending.length >= 5) await flushPending();
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
    _pending.add({
      'message_uid': messageUid,
      'direction': 'in',
      'conversation_type': 'private',
      'target_id': conversationId,
      'message_type': type,
      'payload': payload,
      'sent_at': sentAt.toUtc().toIso8601String(),
    });
    if (_pending.length >= 5) await flushPending();
  }

  @override
  Future<void> backupRecall({
    required String imUserId,
    required String conversationId,
    required String messageUid,
    required DateTime recalledAt,
  }) async {
    _pending.add({
      'message_uid': messageUid,
      'direction': 'recall',
      'conversation_type': 'private',
      'target_id': conversationId,
      'message_type': 'recall',
      'payload': <String, dynamic>{},
      'sent_at': recalledAt.toUtc().toIso8601String(),
    });
    if (_pending.length >= 5) await flushPending();
  }

  @override
  Future<void> flushPending() async {
    if (_pending.isEmpty) return;
    final batch = List<Map<String, dynamic>>.from(_pending);
    _pending.clear();
    try {
      final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
        RongImConfig.backupPath,
        data: {'events': batch},
        converter: (json) => ResultModel.object(
          Map<String, dynamic>.from(json as Map),
          (m) => m,
        ),
      );
      if (result.data?.isSuccess != true) {
        LogUtils.w('[ImBackup] flush failed: ${result.data?.message}');
        _pending.insertAll(0, batch);
      } else {
        LogUtils.i('[ImBackup] flushed ${batch.length} events');
      }
    } catch (e, st) {
      LogUtils.e('[ImBackup] flush error', e, st);
      _pending.insertAll(0, batch);
    }
  }

  int get pendingCount => _pending.length;
}
